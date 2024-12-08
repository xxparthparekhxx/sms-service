import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sms_service/services/storage_service.dart';

class ApiConfig {
  static const String url = "http://192.168.1.6:8000";
}

class ApiCaller {
  final StorageService _storageService;
  String baseUrl = ApiConfig.url;
  final String _refreshTokenEndpoint = "/auth/refresh/";

  ApiCaller(this._storageService);


  Future storeAccessToken(String token) async {
    await _storageService.setValue('authToken', token);
  }

  Future storeRefreshToken(String token) async {
    await _storageService.setValue('refreshToken', token);
  }

  String? getRefreshToken() {
    return _storageService.getValue<String>('refreshToken');
  }

  String? getAccessToken() {
    return _storageService.getValue<String>('authToken');
  }

  Future deleteTokens() async {
    await _storageService.remove('authToken');
    await _storageService.remove('refreshToken');
  }

  Future<String?> _getAuthToken() async {
    return _storageService.getValue<String>('authToken');
  }

  Map<String, String> _getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Function to refresh the access token
  Future<String?> refreshAuthToken() async {
    String? refreshToken = _storageService.getValue<String>('refreshToken');

    final response = await post(
      _refreshTokenEndpoint,
      authenitcated: false,
      body: {'refresh_token': refreshToken},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      String newAccessToken = responseData['access_token'];
      String newRefreshToken = responseData['refresh_token'];

      await _storageService.setValue('authToken', newAccessToken);
      await _storageService.setValue('refreshToken', newRefreshToken);

      return newAccessToken;
    } else {
      print([response.statusCode, response.body].toString());
      return null;
    }
  }

  // Retry mechanism for requests when access token has expired
  Future<http.Response> _retryRequest(
      Future<http.Response> Function() request) async {
    final response = await request();
    debugPrint([response.statusCode, response.body].toString());

    if (response.statusCode == 401) {
      final newToken = await refreshAuthToken();
      if (newToken != null) {
        return await request(); // Retry the original request with a refreshed token
      }
    } else if (response.statusCode == 502) {
      int retryCount = 0;
      const maxRetries = 5;
      while (retryCount < maxRetries) {
        await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
        final retryResponse = await request();
        if (retryResponse.statusCode != 502) {
          return retryResponse;
        }
        retryCount++;
      }
    } else {
      print([response.statusCode, response.body].toString());
    }

    return response;
  }

  Future<http.Response> get(String endpoint) async {
    return _retryRequest(() async {
      final token = await _getAuthToken();
      return await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(token),
      );
    });
  }

  Future<http.Response> post(String endpoint,
      {dynamic body, bool authenitcated = true}) async {
    return _retryRequest(() async {
      String? token;
      if (authenitcated) token = await _getAuthToken();
      return await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(token),
        body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> put(String endpoint, {dynamic body}) async {
    return _retryRequest(() async {
      final token = await _getAuthToken();
      return await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(token),
        body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> patch(String endpoint, {dynamic body}) async {
    return _retryRequest(() async {
      final token = await _getAuthToken();
      return await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(token),
        body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> delete(String endpoint) async {
    return _retryRequest(() async {
      final token = await _getAuthToken();
      return await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(token),
      );
    });
  }

  Future<http.StreamedResponse> multipartRequest(
    String method,
    String endpoint, {
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    final token = await _getAuthToken();
    var request = http.MultipartRequest(method, Uri.parse('$baseUrl$endpoint'));
    request.headers.addAll(_getHeaders(token));

    if (fields != null) request.fields.addAll(fields);
    if (files != null) request.files.addAll(files);

    var response = await request.send();
    print(response);

    // Check for token expiry and retry if necessary
    if (response.statusCode == 403) {
      final newToken = await refreshAuthToken();
      if (newToken != null) {
        request.headers['Authorization'] = 'Bearer $newToken';
        response = await request.send(); // Retry request with new token
      }
    }

    return response;
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode >= 400) {
      debugPrint([response.statusCode, response.body].toString());
    }
  }

  void _checkStreamedResponse(http.StreamedResponse response) {
    if (response.statusCode >= 400) {
      throw HttpException(response.statusCode, 'Error in streamed response');
    }
  }
}

class HttpException implements Exception {
  final int statusCode;
  final String body;

  HttpException(this.statusCode, this.body);

  @override
  String toString() => 'HttpException: $statusCode\n$body';
}
