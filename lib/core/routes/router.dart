import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// 🚀 추가: 초기화할 Provider들을 import
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/inbound_page.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_order_list_provider.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_screen.dart';
import 'package:npda_ui_flutter/features/login/presentation/providers/login_providers.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/outbound_page.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/outbound_page_vm.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_mission_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_order_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/outbound_1f_page.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/outbound_1f_vm.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/providers/outbound_1f_mission_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/providers/outbound_1f_order_list_provider.dart';

import '../../features/splash/presentation/splash_screen.dart';
import '../../presentation/main_shell.dart';
import '../state/session_manager.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // 🚀 추가: 로그아웃 시 모든 관련 상태를 초기화하는 리스너
  ref.listen<SessionState>(sessionManagerProvider, (previous, next) {
    // loggedOut 상태가 되면 모든 상태를 초기화합니다.
    // 세션 만료(expired) 시에는 팝업에서 확인을 누르면 logout()이 호출되어 loggedOut 상태가 됩니다.
    if (next.status == SessionStatus.loggedOut) {
      // 입고
      ref.invalidate(inboundOrderListProvider);
      ref.invalidate(inboundPageVMProvider);
      // 출고
      ref.invalidate(outboundPageVMProvider);
      ref.invalidate(outboundMissionListProvider);
      ref.invalidate(outboundOrderListProvider);
      // 1층 출고
      ref.invalidate(outbound1FVMProvider);
      ref.invalidate(outbound1FMissionListProvider);
      ref.invalidate(outbound1FOrderListProvider);
      // 기타
      ref.invalidate(loginViewModelProvider);
      ref.invalidate(scannerViewModelProvider);
      ref.invalidate(mainShellTabIndexProvider);
    }
  });

  final sessionState = ref.watch(sessionManagerProvider);

  return GoRouter(
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
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
                builder: (context, state) => InboundPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/outbound',
                builder: (context, state) => OutboundPage(),
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
