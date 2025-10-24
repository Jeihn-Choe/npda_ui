import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 🚀 추가
import 'package:npda_ui_flutter/features/inbound/presentation/inbound_screen.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_screen.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/outbound_screen.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/outbound_1f_page.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../presentation/main_shell.dart';
import '../state/session_manager.dart'; // 🚀 추가

// 🚀 수정: GoRouter를 ProviderScope 밖에서 정의할 수 있도록 ProviderRef를 받도록 변경
final routerProvider = Provider<GoRouter>((ref) {
  final sessionState = ref.watch(sessionManagerProvider); // 🚀 sessionState를 watch

  return GoRouter(
    initialLocation: '/splash',
    // 🚀 추가: 리디렉션 로직
    redirect: (context, state) {
      // 스플래시, 로그인 화면은 항상 접근 가능
      final bool loggingIn = state.matchedLocation == '/login';
      final bool splashing = state.matchedLocation == '/splash';

      // 로그인 상태가 아니면 로그인 화면으로 리디렉션
      if (!sessionState.isLoggedIn && !loggingIn && !splashing) {
        return '/login';
      }
      // 로그인 상태인데 로그인/스플래시 화면에 있으려 하면 메인 화면으로 리디렉션
      if (sessionState.isLoggedIn && (loggingIn || splashing)) {
        return '/inbound'; // 로그인 후 기본 화면
      }
      // 그 외의 경우는 현재 경로 유지
      return null;
    },
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
});
