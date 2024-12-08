import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_service/root_provider.dart';
import 'package:sms_service/services/api_service.dart';
import 'package:sms_service/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final apiCaller = ApiCaller(storage);

  runApp(
    ChangeNotifierProvider(
      create: (_) => RootProvider(apiCaller),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'sms worker',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Sms worker'),
        ),
        body: const Center(
          child: Text('init'),
        ),
      ),
    );
  }
}
