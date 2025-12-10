import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/core/routes/router.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';
import 'package:npda_ui_flutter/features/status/presentation/status_page.dart';

import '../core/state/scanner_viewmodel.dart';

class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    // ref.listen 대신 ref.watch를 통해 상태를 직접 확인
    final sessionState = ref.watch(sessionManagerProvider);

    // 빌드가 끝난 직후에 상태를 확인하고 팝업을 띄우는 로직
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

    // 활동 감지 시 호출될 함수
    void resetSessionTimer() {
      ref.read(sessionManagerProvider.notifier).resetSessionTimer();
    }

    return DefaultTabController(
      length: (3),
      child: Stack(
        children: [
          Scaffold(
            key: _scaffoldKey,
            drawer: const StatusPage(),
            appBar: AppBar(
              backgroundColor: AppColors.grey200,
              toolbarHeight: 15,
              leading: IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.celltrionBlack,
                  size: 20,
                ),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        style: const TextStyle(
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
                        icon: const Icon(Icons.logout),
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
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 12,
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: AppColors.celltrionGreen.withAlpha(20),
                        ),

                        tabs: const [
                          Tab(text: '입고'),
                          Tab(text: '출고'),
                          Tab(text: '1층출고'),
                        ],
                        //탭이 선택될 때 GoRouter의 브랜치 변경
                        onTap: (index) {
                          resetSessionTimer(); // 탭 클릭 시 타이머 리셋
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
                          icon: const Icon(Icons.barcode_reader),
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
    ref.read(mainShellTabIndexProvider.notifier).state = index;

    widget.navigationShell.goBranch(
      index,
      // 현재 탭을 다시 탭해도 화면이 새로고침되지 않도록 설정
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}

final mainShellTabIndexProvider = StateProvider<int>((ref) => 0);
