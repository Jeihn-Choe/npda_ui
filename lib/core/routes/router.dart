import 'package:flutter/material.dart'; // 🚀 추가
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/inbound_screen.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_screen.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/outbound_screen.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/outbound_1f_page.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../presentation/main_shell.dart';
import '../state/session_manager.dart';

// 🚀 추가: 앱의 최상단 네비게이터에 접근하기 위한 GlobalKey
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final sessionState = ref.watch(sessionManagerProvider);

  return GoRouter(
    // 🚀 추가: 네비게이터 키 설정
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final bool loggingIn = state.matchedLocation == '/login';
      final bool splashing = state.matchedLocation == '/splash';

      final sessionStatus = sessionState.status;
      final bool loggedIn = sessionStatus == SessionStatus.loggedIn;

      if (sessionStatus == SessionStatus.expired) {
        return null;
      }

      if (!loggedIn && !loggingIn && !splashing) {
        return '/login';
      }

      if (loggedIn && (loggingIn || splashing)) {
        return '/inbound';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbound',
                builder: (context, state) => InboundScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/outbound',
                builder: (context, state) => OutboundScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/outbound_1f',
                builder: (context, state) => const Outbound1FPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
