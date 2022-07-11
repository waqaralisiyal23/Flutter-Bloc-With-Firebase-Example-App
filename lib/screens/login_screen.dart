import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class LoginScreen extends HookWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
    );
  }
}
