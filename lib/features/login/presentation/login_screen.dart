import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';
import 'package:npda_ui_flutter/features/login/presentation/providers/login_providers.dart';

import '../../../core/constants/colors.dart';
import 'widgets/custom_text_field.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginViewModelProvider);
    final sessionState = ref.watch(sessionManagerProvider);

    /// provider 통해 생성된 viewmodel의 인스턴스에 접근하기 위해 notifier 사용
    final viewmodel = ref.watch(loginViewModelProvider.notifier);

    // 로그인 상태 변화 감지 및 리디렉션은 router.dart에서 중앙 관리합니다.

    /// 키보드 높이 감지해서 키보드 올라올 때도 화면이 잘 보이도록 함.
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(
              horizontal: 32,
              vertical: isKeyboardVisible ? 0 : 32,
            ),
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey400.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isKeyboardVisible ? 20.0 : 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isKeyboardVisible ? 0 : 16,
                    ),
                    child: Text(
                      'Celltrion NPDA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isKeyboardVisible ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.celltrionGreen,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  SizedBox(height: isKeyboardVisible ? 2 : 30),
                  CustomTextField(
                    controller: viewmodel.userIdController,
                    labelText: 'ID',
                  ),
                  SizedBox(height: isKeyboardVisible ? 2 : 20),
                  CustomTextField(
                    controller: viewmodel.passwordController,
                    labelText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: isKeyboardVisible ? 2 : 32),

                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isKeyboardVisible ? 2 : 16),
                  ],

                  ElevatedButton(
                    onPressed: () {
                      final userId = viewmodel.userIdController.text;
                      final password = viewmodel.passwordController.text;

                      viewmodel.login(context, userId, password);

                      /// testLogin 사용
                      /// 아이디/비번 상관없이 로그인 처리
                      /// viewmodel.testLogin(context, userId, password);
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.celltrionGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: AppColors.celltrionGreen.withAlpha(30),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
