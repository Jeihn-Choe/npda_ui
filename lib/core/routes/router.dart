import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/inbound_screen.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_screen.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../presentation/main_shell.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 스플래시 화면
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    // 로그인 화면
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(), // TODO: 실제 로그인 화면
    ),

    //메인 화면을 위한 셸 라우트
    StatefulShellRoute.indexedStack(
      // 셸 UI 위젯 빌더
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        // 입고 화면
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/inbound',
              builder: (context, state) => InboundScreen(),
            ),
          ],
        ),
        // 출고 화면
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/outbound',

              // builder: (context, state) => OutboundScreen(),
              builder: (context, state) =>
                  const _PlaceholderScreen(title: '출고 화면', color: Colors.green),
            ),
          ],
        ),
        // 1층 출고 화면
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/outbound_1f',
              // builder: (context, state) => Outbound1fScreen(),
              builder: (context, state) => const _PlaceholderScreen(
                title: '1층 출고 화면',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);

//TODO : 기능 구현 시 실제 화면으로 대체할 임시 위젯
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final Color color;

  const _PlaceholderScreen({
    super.key,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color.withAlpha(10),
      body: Center(
        child: Text(
          '$title 테스트용화면',
          style: TextStyle(fontSize: 12, color: color),
        ),
      ),
    );
  }
}
