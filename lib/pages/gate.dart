import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sms_service/pages/home.dart';
import 'package:sms_service/pages/login.dart';
import 'package:sms_service/root_provider.dart';

class AppGate extends StatelessWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthStatus state = Provider.of<RootProvider>(context).state;
    if (state == AuthStatus.authenticated) {
      return const HomePage();
    } else {
      return const LoginScreen();
    }
  }
}
