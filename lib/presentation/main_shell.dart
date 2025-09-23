import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';

import '../core/services/scan_event_service.dart';
import '../core/state/scanner_viewmodel.dart';
import '../features/login/presentation/providers/login_providers.dart';

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
    final loginState = ref.watch(loginViewModelProvider);
    final isScannerModeActive = ref.watch(scannerViewModelProvider);
    final scanEventService = ref.watch(scanEventServiceProvider);

    // scannedDataProvider ref.listen으로 구독
    // StreamProvider는 AsyncValue를 반환하므로 next.when을 사용하여 데이터, 로딩, 에러 상태 처리
    ref.listen<AsyncValue<String>>(scannedDataStreamProvider, (previous, next) {
      next.when(
        data: (scannedData) {
          if (isScannerModeActive) {
            final currentPath = GoRouter.of(context);

            logger('Scanned Data: $scannedData, Current Path: $currentPath');
            logger('스캐너모드 토글상태 (ref.listen 내부): $isScannerModeActive');

            switch (currentPath) {
              case '/inbound':
                // 입고 화면에서 스캔된 데이터 처리
                // 예: ref.read(inboundViewModelProvider.notifier).processScannedData(scannedData);

                logger("inbound 스캔상태변경");
                ref
                    .read(inboundViewModelProvider.notifier)
                    .handleScannedData(scannedData);

                break;
              case '/outbound':
                // 출고 화면에서 스캔된 데이터 처리
                // 예: ref.read(outboundViewModelProvider.notifier).processScannedData(scannedData);

                logger("outbound 스캔상태변경");

                break;
              case '/outbound_1f':
                // 1층 출고 화면에서 스캔된 데이터 처리
                // 예: ref.read(firstFloorOutboundViewModelProvider.notifier).processScannedData(scannedData);

                logger("1층출고 스캔상태변경");

                break;
              default:
                // 다른 경로에서는 스캔된 데이터를 무시하거나 기본 동작 수행
                break;
            }
          }
        },
        loading: () {
          // 로딩 상태 처리 (필요시)
        },
        error: (error, stack) {
          logger("error : $error");
        },
      );
    });

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: scanEventService.handleKeyEvent,
      autofocus: true,
      child: DefaultTabController(
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
                          '${loginState.userId} ${loginState.userName}님',
                        ),
                        IconButton(
                          onPressed: () {},
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
                          onTap: (index) => _onTap(context, index),
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
                            border: Border.all(color: Colors.grey),
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

                              logger(
                                "스캐너모드 토글상태 : ${ref.read(scannerViewModelProvider)}",
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // 탭에 따라 다른 화면을 보여주는 Shell
              body: widget.navigationShell,
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    widget.navigationShell.goBranch(
      index,
      // 현재 탭을 다시 탭해도 화면이 새로고침되지 않도록 설정
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }
}
