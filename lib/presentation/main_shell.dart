import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/core/routes/router.dart';
// 🚀 삭제: import 'package:npda_ui_flutter/features/login/presentation/providers/login_providers.dart';
// 🚀 추가: SessionManagerNotifier import
import 'package:npda_ui_flutter/core/state/session_manager.dart';

import '../core/state/scanner_viewmodel.dart';

class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🚀 수정: ref.listen 대신 ref.watch를 통해 상태를 직접 확인
    final sessionState = ref.watch(sessionManagerProvider);

    // 🚀 추가: 빌드가 끝난 직후에 상태를 확인하고 팝업을 띄우는 로직
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 세션이 만료되었고, 아직 팝업이 표시되지 않았다면 팝업을 띄웁니다.
      if (sessionState.status == SessionStatus.expired &&
          ModalRoute.of(rootNavigatorKey.currentContext!)?.isCurrent != true) {
        final context = rootNavigatorKey.currentContext;
        if (context == null) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('세션 만료'),
              content: const Text('장시간 활동이 없어 자동으로 로그아웃됩니다.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                    ref.read(sessionManagerProvider.notifier).logout();
                  },
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }
    });
    final isScannerModeActive = ref.watch(scannerViewModelProvider);

    // ✨ 활동 감지 시 호출될 함수
    void resetSessionTimer() {
      ref
          .read(sessionManagerProvider.notifier)
          .resetSessionTimer(); // 🚀 수정: .notifier 추가
      // logger('Session timer has been reset.'); // 디버깅용
    }

    return DefaultTabController(
      length: (3),
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.grey200,
              toolbarHeight: 15,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      color: AppColors.celltrionBlack,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    'RCS 연동 NPDA',
                  ),
                  Row(
                    children: [
                      Text(
                        style: TextStyle(
                          color: AppColors.grey900,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        '${sessionState.userId} ${sessionState.userName}님',
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(sessionManagerProvider.notifier).logout();
                        },
                        icon: Icon(Icons.logout),
                        color: AppColors.grey900,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Row(
                  children: [
                    Expanded(
                      child: TabBar(
                        labelColor: AppColors.celltrionGreen,
                        unselectedLabelColor: AppColors.lightGrey,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        unselectedLabelStyle: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.celltrionGreen.withAlpha(20),
                        ),

                        tabs: [
                          Tab(text: '입고'),
                          Tab(text: '출고'),
                          Tab(text: '1층출고'),
                        ],
                        //탭이 선택될 때 GoRouter의 브랜치 변경
                        onTap: (index) {
                          resetSessionTimer(); // ✨ 추가: 탭 클릭 시 타이머 리셋
                          _onTap(context, index);
                        },
                      ),
                    ),

                    /// 우측 바코드 아이콘 버튼
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, left: 32.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isScannerModeActive
                              ? Colors.deepPurple.withAlpha(100)
                              : Colors.grey.withAlpha(20),
                          border: Border.all(color: Colors.white54),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.barcode_reader),
                          color: isScannerModeActive
                              ? Colors.deepPurple
                              : Colors.grey,
                          onPressed: () {
                            ref
                                .read(scannerViewModelProvider.notifier)
                                .toggleScannerMode();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 탭에 따라 다른 화면을 보여주는 Shell
            body: GestureDetector(
              // ✨ 추가: 화면 전체 감싸기
              onTap: resetSessionTimer,
              onPanDown: (_) => resetSessionTimer(),
              behavior: HitTestBehavior.translucent,
              child: widget.navigationShell,
            ),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    //Provider에 현재 탭 인덱스 저장
    ref.read(mainShellTabIndexProvider.notifier).state = index; // modified

    widget.navigationShell.goBranch(
      index,
      // 현재 탭을 다시 탭해도 화면이 새로고침되지 않도록 설정
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

final mainShellTabIndexProvider = StateProvider<int>((ref) => 0);
