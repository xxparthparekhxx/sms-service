import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sms_service/pages/gate.dart';
import 'package:sms_service/root_provider.dart';
import 'package:sms_service/services/api_service.dart';
import 'package:sms_service/services/messaging_service.dart';
import 'package:sms_service/services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final apiCaller = ApiCaller(storage);
  final messagingService = MessagingService(apiCaller);
  await messagingService.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => RootProvider(apiCaller, storage),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'sms worker',
      home: AppGate(),
    );
  }
}
