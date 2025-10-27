import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/popups/outbound_popup.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_mission_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_order_list_provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/state/session_manager.dart';
import '../../../presentation/main_shell.dart';
import '../../../presentation/widgets/form_card_layout.dart';
import '../../../presentation/widgets/info_field_widget.dart';
import 'outbound_screen_vm.dart';

class OutboundScreen extends ConsumerStatefulWidget {
  const OutboundScreen({super.key});

  @override
  ConsumerState<OutboundScreen> createState() => _OutboundScreenState();
}

class _OutboundScreenState extends ConsumerState<OutboundScreen> {
  late FocusNode _scannerFocusNode;
  late TextEditingController _scannerTextController;

  @override
  void initState() {
    super.initState();
    _scannerFocusNode = FocusNode();
    _scannerTextController = TextEditingController();

    _scannerFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // 🚀 추가된 부분: 로그인 상태가 아닐 경우, 포커스 로직을 실행하지 않음
    final sessionStatus = ref.read(sessionManagerProvider).status;
    if (sessionStatus != SessionStatus.loggedIn) return;

    final currentTabIndex = ref.read(mainShellTabIndexProvider);
    if (currentTabIndex != 1) return;

    final outboundState = ref.read(outboundScreenViewModelProvider);
    if (!_scannerFocusNode.hasFocus && !outboundState.showOutboundPopup) {
      FocusScope.of(context).requestFocus(_scannerFocusNode);
      appLogger.d("포커스 다시 가져옴");
    }
  }

  @override
  void dispose() {
    _scannerFocusNode.removeListener(_onFocusChange);
    _scannerFocusNode.dispose();
    _scannerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✨ 각 Provider와 ViewModel의 상태를 개별적으로 watch
    final outboundState = ref.watch(outboundScreenViewModelProvider);
    final orderListState = ref.watch(outboundOrderListProvider);
    final missionListState = ref.watch(outboundMissionListProvider);

    ref.listen<OutboundScreenState>(outboundScreenViewModelProvider, (
      previous,
      next,
    ) {
      if (next.showOutboundPopup && previous?.showOutboundPopup == false) {
        _scannerFocusNode.unfocus();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return OutboundPopup(scannedData: next.scannedDataForPopup);
          },
        ).then((_) {
          if (mounted) {
            // ✨ closeCreationPopup의 불필요한 파라미터 제거
            ref
                .read(outboundScreenViewModelProvider.notifier)
                .closeCreationPopup();

            FocusScope.of(context).requestFocus(_scannerFocusNode);
            appLogger.d("팝업 닫힘 - 포커스 다시 가져옴");
          }
        });
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Opacity(
                opacity: 0.0,
                child: SizedBox(
                  width: 0.0,
                  height: 0.0,
                  child: TextField(
                    focusNode: _scannerFocusNode,
                    controller: _scannerTextController,
                    autofocus: true,
                    keyboardType: TextInputType.none,
                    enabled: !outboundState.showOutboundPopup,
                    onSubmitted: (value) {
                      final currentOutboundState = ref.read(
                        outboundScreenViewModelProvider,
                      );
                      if (currentOutboundState.showOutboundPopup) {
                        appLogger.d("팝업이 떠있는 상태에서 스캔 입력이 들어왔습니다. 무시합니다.");
                        _scannerTextController.clear();
                        return;
                      }
                      appLogger.d("아웃바운드 화면 스캐너 입력 감지 : $value");
                      ref
                          .read(outboundScreenViewModelProvider.notifier)
                          .handleScannedData(value);
                      _scannerTextController.clear();
                      appLogger.d("텍스트필드 초기화");

                      if (!currentOutboundState.showOutboundPopup) {
                        FocusScope.of(context).requestFocus(_scannerFocusNode);
                        logger("포커스 다시 가져옴");
                      }
                    },
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                // ✨ Mission 관련 상태 참조를 ViewModel -> Provider로 변경
                child: missionListState.isMissionSelectionModeActive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                // ✨ 상태 참조 변경
                                missionListState.selectedMissionNos.isEmpty ||
                                    missionListState.isMissionDeleting
                                ? null
                                : () async {
                                    // ✨ 메소드 호출 변경
                                    final success = await ref
                                        .read(
                                          outboundMissionListProvider.notifier,
                                        )
                                        .deleteSelectedOutboundMissions();

                                    if (!context.mounted) return;

                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: Text(success ? '성공' : '실패'),
                                          content: Text(
                                            success
                                                ? '선택된 미션이 삭제되었습니다.'
                                                : '미션 삭제에 실패했습니다.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                dialogContext,
                                              ).pop(),
                                              child: const Text('확인'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (success) {
                                      // ✨ 메소드 호출 변경
                                      ref
                                          .read(
                                            outboundMissionListProvider
                                                .notifier,
                                          )
                                          .disableSelectionMode();
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child:
                                // ✨ 상태 참조 변경
                                missionListState.isMissionDeleting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    '선택 항목 삭제 (${missionListState.selectedMissionNos.length})',
                                  ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // ✨ 메소드 호출 변경
                              ref
                                  .read(outboundMissionListProvider.notifier)
                                  .disableSelectionMode();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('취소'),
                          ),
                        ],
                      )
                    : orderListState.isOrderSelectionModeActive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                orderListState.selectedOrderNos.isEmpty ||
                                    orderListState.isOrderDeleting
                                ? null
                                : () async {
                                    ref
                                        .read(
                                          outboundOrderListProvider.notifier,
                                        )
                                        .deleteSelectedOrders();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: orderListState.isOrderDeleting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    '선택 항목 삭제 (${orderListState.selectedOrderNos.length})',
                                  ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(outboundOrderListProvider.notifier)
                                  .disableOrderSelectionMode();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('취소'),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('삭제'),
                          ),
                          ElevatedButton(
                            onPressed:
                                orderListState.orders.isEmpty ||
                                    orderListState.isLoading
                                ? null
                                : () {
                                    ref
                                        .read(
                                          outboundOrderListProvider.notifier,
                                        )
                                        .requestOutboundOrder();
                                  },

                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.celltrionGreen,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: orderListState.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(' 작업 시작 '),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _scannerFocusNode.unfocus();
                              ref
                                  .read(
                                    outboundScreenViewModelProvider.notifier,
                                  )
                                  .showCreationPopup();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade500,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: const Text('생성'),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 4),

              if (orderListState.orders.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(90),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      Text(
                        style: TextStyle(
                          color: AppColors.celltrionBlack,
                          fontWeight: FontWeight.bold,
                        ),
                        "출고 요청 List (${orderListState.orders.length}건)",
                      ),
                      const SizedBox(height: 4),
                      DataTable(
                        horizontalMargin: 8,
                        columnSpacing: 8,
                        headingRowHeight: 28,
                        dataRowMinHeight: 20,
                        dataRowMaxHeight: 40,
                        headingTextStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        dataTextStyle: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                        showCheckboxColumn:
                            orderListState.isOrderSelectionModeActive,
                        columns: const [
                          DataColumn(label: Text('DO No / 저장빈 No.')),
                          DataColumn(label: Text('요청시간')),
                        ],
                        rows: orderListState.orders.map((order) {
                          return DataRow(
                            selected:
                                orderListState.isOrderSelectionModeActive &&
                                orderListState.selectedOrderNos.contains(
                                  order.orderNo,
                                ),
                            onSelectChanged: (isSelected) {
                              if (orderListState.isOrderSelectionModeActive) {
                                ref
                                    .read(outboundOrderListProvider.notifier)
                                    .toggleOrderForDeletion(order.orderNo);
                              }
                            },
                            cells: [
                              DataCell(
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onLongPress: () {
                                    ref
                                        .read(
                                          outboundOrderListProvider.notifier,
                                        )
                                        .enableOrderSelectionMode(
                                          order.orderNo,
                                        );
                                  },
                                  onTap: () {
                                    if (orderListState
                                        .isOrderSelectionModeActive) {
                                      ref
                                          .read(
                                            outboundOrderListProvider.notifier,
                                          )
                                          .toggleOrderForDeletion(
                                            order.orderNo,
                                          );
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Text(
                                      order.savedBinNo ?? order.doNo ?? "-",
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onLongPress: () {
                                    ref
                                        .read(
                                          outboundOrderListProvider.notifier,
                                        )
                                        .enableOrderSelectionMode(
                                          order.orderNo,
                                        );
                                  },
                                  onTap: () {
                                    if (orderListState
                                        .isOrderSelectionModeActive) {
                                      ref
                                          .read(
                                            outboundOrderListProvider.notifier,
                                          )
                                          .toggleOrderForDeletion(
                                            order.orderNo,
                                          );
                                    }
                                  },
                                  child: Container(
                                    alignment: Alignment.centerLeft,
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: Text(
                                      DateFormat(
                                        'yyyy-MM-dd HH:mm:ss',
                                      ).format(order.startTime),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              // ✨ Mission 상세 정보 표시도 Provider 상태를 사용
              FormCardLayout(
                contentPadding: 12,
                verticalMargin: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          InfoFieldWidget(
                            fieldName: 'No.',
                            fieldValue: missionListState.selectedMission?.doNo
                                .toString(),
                          ),
                          InfoFieldWidget(
                            fieldName: '출발지',
                            fieldValue:
                                missionListState.selectedMission?.sourceBin,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          InfoFieldWidget(
                            fieldName: '시간',
                            fieldValue: missionListState
                                .selectedMission
                                ?.startTime
                                .toString(),
                          ),
                          InfoFieldWidget(
                            fieldName: '목적지',
                            fieldValue: missionListState
                                .selectedMission
                                ?.destinationBin
                                .toString(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ✨ Mission 목록 로딩 상태도 Provider 상태를 사용
              if (missionListState.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(100),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                Container(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(90),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DataTable(
                      horizontalMargin: 8,
                      columnSpacing: 16,
                      headingRowHeight: 36,
                      dataRowMinHeight: 36,
                      dataRowMaxHeight: 36,
                      headingTextStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      dataTextStyle: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      columns: const [
                        DataColumn(label: Text('No.')),
                        DataColumn(label: Text('PltNo.')),
                        DataColumn(label: Text('출발지')),
                        DataColumn(label: Text('목적지')),
                      ],

                      rows: missionListState.missions.map((mission) {
                        DataCell buildTappableCell(Widget child) {
                          return DataCell(
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onLongPress: () {
                                // ✨ 메소드 호출 변경
                                ref
                                    .read(outboundMissionListProvider.notifier)
                                    .enableSelectionMode(mission.missionNo);
                              },
                              onTap: () {
                                // ✨ 상태 참조 변경
                                if (missionListState
                                    .isMissionSelectionModeActive) {
                                  // ✨ 메소드 호출 변경
                                  ref
                                      .read(
                                        outboundMissionListProvider.notifier,
                                      )
                                      .toggleMissionForDeletion(
                                        mission.missionNo,
                                      );
                                } else {
                                  // ✨ 메소드 호출 변경
                                  ref
                                      .read(
                                        outboundMissionListProvider.notifier,
                                      )
                                      .selectMission(mission);
                                }
                              },
                              child: child,
                            ),
                          );
                        }

                        return DataRow(
                          // ✨ 상태 참조 변경
                          selected:
                              missionListState.isMissionSelectionModeActive &&
                              missionListState.selectedMissionNos.contains(
                                mission.missionNo,
                              ),

                          onSelectChanged:
                              // ✨ 상태 참조 변경
                              missionListState.isMissionSelectionModeActive
                              ? (isSelected) {
                                  // ✨ 메소드 호출 변경
                                  ref
                                      .read(
                                        outboundMissionListProvider.notifier,
                                      )
                                      .toggleMissionForDeletion(
                                        mission.missionNo,
                                      );
                                }
                              : null,

                          cells: [
                            buildTappableCell(
                              Text(mission.missionNo.toString()),
                            ),
                            buildTappableCell(
                              Text(mission.doNo ?? mission.sourceBin ?? "-"),
                            ),
                            buildTappableCell(Text(mission.sourceBin)),
                            buildTappableCell(Text(mission.destinationBin)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
