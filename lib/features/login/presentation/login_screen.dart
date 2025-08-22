import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/inbound'); // 로그인 후 입고 화면으로 이동
            // 실제 로그인 로직은 ViewModel에서 처리
            // 예: LoginViewModel의 login() 메서드 호출
            // 로그인 성공 시 /inbound로 이동
          },
          child: const Text('Login'),
        ),
      ),
    );
  }
}
