import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/popups/outbound_1f_popup.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/providers/outbound_1f_mission_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/providers/outbound_1f_order_list_provider.dart';

import '../../../core/constants/colors.dart';
import '../../../presentation/main_shell.dart';
import '../../../presentation/widgets/form_card_layout.dart';
import '../../../presentation/widgets/info_field_widget.dart';
import 'outbound_1f_vm.dart';

class Outbound1FPage extends ConsumerStatefulWidget {
  const Outbound1FPage({super.key});

  @override
  ConsumerState<Outbound1FPage> createState() => _Outbound1FPageState();
}

class _Outbound1FPageState extends ConsumerState<Outbound1FPage> {
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
    final currentTabIndex = ref.read(mainShellTabIndexProvider);
    if (currentTabIndex != 2) return;

    final vmState = ref.read(outbound1FVMProvider);
    if (!_scannerFocusNode.hasFocus && !vmState.showOutboundPopup) {
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
    // ✨ 1. 각 Provider의 상태를 watch
    final vmState = ref.watch(outbound1FVMProvider);
    final orderListState = ref.watch(outbound1FOrderListProvider);
    final missionListState = ref.watch(outbound1FMissionListProvider);

    // 팝업 로직은 VM을 계속 사용
    ref.listen<Outbound1FState>(outbound1FVMProvider, (previous, next) {
      if (next.showOutboundPopup && previous?.showOutboundPopup == false) {
        _scannerFocusNode.unfocus();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return Outbound1FPopup(scannedData: next.scannedDataForPopup);
          },
        ).then((_) {
          if (mounted) {
            ref.read(outbound1FVMProvider.notifier).closeCreationPopup();
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
                    enabled: !vmState.showOutboundPopup,
                    onSubmitted: (value) {
                      if (vmState.showOutboundPopup) {
                        _scannerTextController.clear();
                        return;
                      }
                      ref
                          .read(outbound1FVMProvider.notifier)
                          .handleScannedData(value);
                      _scannerTextController.clear();
                      if (!vmState.showOutboundPopup) {
                        FocusScope.of(context).requestFocus(_scannerFocusNode);
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
                // ✨ 2. 올바른 Provider 상태를 버튼 빌더에 전달
                child: _buildTopButtons(missionListState, orderListState),
              ),
              const SizedBox(height: 4),
              if (orderListState.orders.isNotEmpty)
                _buildOrderList(orderListState),
              FormCardLayout(
                contentPadding: 12,
                verticalMargin: 4,
                child: _buildMissionDetails(vmState),
              ),
              const SizedBox(height: 8),
              if (missionListState.isMissionListLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(100),
                    child: CircularProgressIndicator(),
                  ),
                )
              else
                _buildMissionDataTable(missionListState),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ 3. 버튼 빌더의 파라미터 및 로직 수정
  Widget _buildTopButtons(
    Outbound1FMissionListState missionListState,
    Outbound1FOrderListState orderListState,
  ) {
    if (missionListState.isMissionSelectionModeActive) {
      return _buildMissionSelectionButtons(missionListState);
    } else if (orderListState.isOrderSelectionModeActive) {
      return _buildOrderSelectionButtons(orderListState);
    } else {
      return _buildDefaultButtons(orderListState);
    }
  }

  Widget _buildMissionSelectionButtons(
      Outbound1FMissionListState missionListState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: missionListState.selectedMissionNos.isEmpty ||
                  missionListState.isMissionDeleting
              ? null
              : () async {
                  // ✨ MissionListProvider의 메서드 호출
                  final success = await ref
                      .read(outbound1FMissionListProvider.notifier)
                      .deleteSelectedMissions();
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text(success ? '성공' : '실패'),
                        content: Text(
                          success ? '선택된 미션이 삭제되었습니다.' : '미션 삭제에 실패했습니다.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('확인'),
                          ),
                        ],
                      );
                    },
                  );
                  // 성공 시 별도 모드 해제 호출 필요 없음 (Provider 내부에서 처리)
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: missionListState.isMissionDeleting
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : Text(
                  '선택 항목 삭제 (${missionListState.selectedMissionNos.length})'),
        ),
        ElevatedButton(
          onPressed: () {
            // ✨ MissionListProvider의 메서드 호출
            ref.read(outbound1FMissionListProvider.notifier).disableSelectionMode();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('취소'),
        ),
      ],
    );
  }

  Widget _buildOrderSelectionButtons(Outbound1FOrderListState orderListState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: orderListState.selectedOrderNos.isEmpty ||
                  orderListState.isOrderDeleting
              ? null
              : () {
                  // ✨ OrderListProvider의 메서드 호출
                  ref
                      .read(outbound1FOrderListProvider.notifier)
                      .deleteSelectedOrders();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: orderListState.isOrderDeleting
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : Text('선택 항목 삭제 (${orderListState.selectedOrderNos.length})'),
        ),
        ElevatedButton(
          onPressed: () {
            // ✨ OrderListProvider의 메서드 호출
            ref
                .read(outbound1FOrderListProvider.notifier)
                .disableOrderSelectionMode();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('취소'),
        ),
      ],
    );
  }

  Widget _buildDefaultButtons(Outbound1FOrderListState orderListState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: null, // Or implement a general delete functionality
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('삭제'),
        ),
        ElevatedButton(
          onPressed: orderListState.orders.isEmpty || orderListState.isLoading
              ? null
              : () {
                  ref
                      .read(outbound1FOrderListProvider.notifier)
                      .requestOutboundOrder();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.celltrionGreen,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            ref.read(outbound1FVMProvider.notifier).showCreationPopup();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade500,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text('생성'),
        ),
      ],
    );
  }

  // ✨ 4. Order 리스트 빌더 수정
  Widget _buildOrderList(Outbound1FOrderListState orderListState) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
            "출고(1F) 요청 List (${orderListState.orders.length}건)",
          ),
          const SizedBox(height: 4),
          DataTable(
            horizontalMargin: 8,
            columnSpacing: 8,
            headingRowHeight: 28,
            dataRowMinHeight: 20,
            dataRowMaxHeight: 40,
            showCheckboxColumn: orderListState.isOrderSelectionModeActive,
            columns: const [
              DataColumn(label: Text('피킹/언로드 Area')),
              DataColumn(label: Text('요청시간')),
            ],
            rows: orderListState.orders.map((order) {
              return DataRow(
                selected: orderListState.selectedOrderNos.contains(order.orderNo),
                onSelectChanged: (isSelected) {
                  if (orderListState.isOrderSelectionModeActive) {
                    ref
                        .read(outbound1FOrderListProvider.notifier)
                        .toggleOrderForDeletion(order.orderNo);
                  }
                },
                cells: [
                  DataCell(
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () {
                        ref
                            .read(outbound1FOrderListProvider.notifier)
                            .enableOrderSelectionMode(order.orderNo);
                      },
                      onTap: () {
                        if (orderListState.isOrderSelectionModeActive) {
                          ref
                              .read(outbound1FOrderListProvider.notifier)
                              .toggleOrderForDeletion(order.orderNo);
                        }
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        width: double.infinity,
                        height: double.infinity,
                        child: Text(
                          order.pickingArea ?? order.unloadArea ?? "-",
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onLongPress: () {
                        ref
                            .read(outbound1FOrderListProvider.notifier)
                            .enableOrderSelectionMode(order.orderNo);
                      },
                      onTap: () {
                        if (orderListState.isOrderSelectionModeActive) {
                          ref
                              .read(outbound1FOrderListProvider.notifier)
                              .toggleOrderForDeletion(order.orderNo);
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
    );
  }

  // 상세 정보 표시는 VM의 상태를 그대로 사용
  Widget _buildMissionDetails(Outbound1FState vmState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            children: [
              InfoFieldWidget(
                fieldName: 'No.',
                fieldValue: vmState.selectedMission?.subMissionNo.toString(),
              ),
              InfoFieldWidget(
                fieldName: '출발지',
                fieldValue: vmState.selectedMission?.sourceBin,
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
                fieldValue: vmState.selectedMission?.startTime,
              ),
              InfoFieldWidget(
                fieldName: '목적지',
                fieldValue: vmState.selectedMission?.destinationBin,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✨ 5. Mission 데이터 테이블 빌더 수정
  Widget _buildMissionDataTable(Outbound1FMissionListState missionListState) {
    return Container(
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
        showCheckboxColumn: missionListState.isMissionSelectionModeActive,
        horizontalMargin: 8,
        columnSpacing: 16,
        headingRowHeight: 36,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 36,
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
                  // ✨ MissionListProvider의 메서드 호출
                  ref
                      .read(outbound1FMissionListProvider.notifier)
                      .enableSelectionMode(mission.subMissionNo);
                },
                onTap: () {
                  if (missionListState.isMissionSelectionModeActive) {
                    // ✨ MissionListProvider의 메서드 호출
                    ref
                        .read(outbound1FMissionListProvider.notifier)
                        .toggleMissionForDeletion(mission.subMissionNo);
                  } else {
                    // ✨ VM의 메서드 호출 (상세 정보 표시)
                    ref
                        .read(outbound1FVMProvider.notifier)
                        .selectMission(mission);
                  }
                },
                child: child,
              ),
            );
          }

          return DataRow(
            selected: missionListState.selectedMissionNos
                .contains(mission.subMissionNo),
            onSelectChanged: (isSelected) {
              if (missionListState.isMissionSelectionModeActive) {
                // ✨ MissionListProvider의 메서드 호출
                ref
                    .read(outbound1FMissionListProvider.notifier)
                    .toggleMissionForDeletion(mission.subMissionNo);
              }
            },
            cells: [
              buildTappableCell(Text(mission.subMissionNo.toString())),
              buildTappableCell(Text(mission.pltNo)),
              buildTappableCell(Text(mission.sourceBin)),
              buildTappableCell(Text(mission.destinationBin)),
            ],
          );
        }).toList(),
      ),
    );
  }
}