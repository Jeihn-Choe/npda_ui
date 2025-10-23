import 'package:go_router/go_router.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/inbound_screen.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_screen.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/outbound_screen.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/outbound_1f_page.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../presentation/main_shell.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 스플래시 화면
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    // 로그인 화면
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

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
              builder: (context, state) => OutboundScreen(),
            ),
          ],
        ),
        // 1층 출고 화면
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/outbound_1f',
              // builder: (context, state) => Outbound1fScreen(),
              builder: (context, state) => const Outbound1FPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
