import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sms_service/models/device.dart';
import 'package:sms_service/services/api_service.dart';
import 'package:sms_service/services/storage_service.dart';

enum AuthStatus {
  authenticated,
  unauthenticated,
}

class RootProvider extends ChangeNotifier {
  final ApiCaller _apiCaller;
  final StorageService _storageService;
  AuthStatus state = AuthStatus.unauthenticated;
  bool _isLoading = true;

  RootProvider(this._apiCaller, this._storageService) {
    _checkAuthStatus();
    if (state == AuthStatus.authenticated) {
      _isLoading = true;
      notifyListeners();
    }
  }

  Future<void> setServerUrl(String url) async {
    _apiCaller.setBaseUrl(url);
    notifyListeners();
  }

  AuthStatus get isAuthenticated => state;
  bool get isLoading => _isLoading;

  Future<void> _checkAuthStatus() async {
    final token = _apiCaller.getAccessToken();
    state =
        token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiCaller.post(
        '/api/login/',
        body: {
          'username': username,
          'password': password,
        },
        authenitcated: false,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _apiCaller.storeAccessToken(data['access_token']);
        await _apiCaller.storeRefreshToken(data['refresh_token']);
        state = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _apiCaller.deleteTokens();
    state = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<Device?> createDevice(Device device) async {
    final response = await _apiCaller.post(
      '/api/devices/',
      body: device.toJson(),
    );

    if (response.statusCode == 201) {
      final newDevice = Device.fromJson(json.decode(response.body));
      notifyListeners();
      return newDevice;
    }
    return null;
  }
}
