import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/inbound_page_vm.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_mission_list_provider.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_order_list_provider.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup.dart';
import 'package:npda_ui_flutter/presentation/widgets/form_card_layout.dart';
import 'package:npda_ui_flutter/presentation/widgets/info_field_widget.dart';

import '../../../core/state/session_manager.dart';
import '../../../presentation/main_shell.dart';

class InboundPage extends ConsumerStatefulWidget {
  const InboundPage({super.key});

  @override
  ConsumerState<InboundPage> createState() => _InboundPageState();
}

class _InboundPageState extends ConsumerState<InboundPage> {
  late FocusNode _scannerFocusNode; // 스캐너 입력용 FocusNode
  late TextEditingController _scannerTextController;

  @override
  void initState() {
    super.initState();
    _scannerFocusNode = FocusNode();
    _scannerTextController = TextEditingController();
    _scannerFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _scannerFocusNode.removeListener(_onFocusChange);
    _scannerFocusNode.dispose();
    _scannerTextController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    final sessionStatus = ref.read(sessionManagerProvider).status;
    if (sessionStatus != SessionStatus.loggedIn) return;

    final currentTabIndex = ref.read(mainShellTabIndexProvider);
    if (currentTabIndex != 0) return;

    final pageState = ref.read(inboundPageVMProvider);
    if (!pageState.showInboundPopup && !_scannerFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_scannerFocusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Provider 구독 분리
    final pageState = ref.watch(inboundPageVMProvider);
    final orderState = ref.watch(inboundOrderListProvider);
    final missionState = ref.watch(inboundMissionListProvider);

    // 2. 각 State에서 필요한 변수 추출
    final inboundOrderItems = orderState.orders;
    final selectedOrderPltNos = orderState.selectedPltNos;
    final isOrderSelectionMode = selectedOrderPltNos.isNotEmpty;

    final inboundMissions = missionState.missions;
    final isLoadingMissions = missionState.isLoading;
    final selectedMissionNos = missionState.selectedMissionNos;
    final selectedMission = missionState.selectedMission;
    final isMissionSelectionMode = missionState.isSelectionModeActive;

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    // 3. PageViewModel의 팝업 상태 감지
    ref.listen<InboundPageState>(inboundPageVMProvider, (previous, next) {
      if (next.showInboundPopup && (previous?.showInboundPopup == false)) {
        _scannerFocusNode.unfocus();
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return MediaQuery(
              data: MediaQuery.of(
                dialogContext,
              ).copyWith(viewInsets: EdgeInsets.zero),
              child: InboundRegistrationPopup(
                scannedData: next.scannedDataForPopup,
              ),
            );
          },
        ).then((_) {
          if (mounted) {
            ref
                .read(inboundPageVMProvider.notifier)
                .setInboundPopupState(false);
            ref.read(inboundRegistrationPopupViewModelProvider).resetForm();
            ref.read(inboundPageVMProvider.notifier).clearInboundPopup();
            ref.invalidate(inboundRegistrationPopupViewModelProvider);
            FocusScope.of(context).requestFocus(_scannerFocusNode);
          }
        });
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
                    enabled: !pageState.showInboundPopup,
                    onSubmitted: (value) {
                      if (ref.read(inboundPageVMProvider).showInboundPopup) {
                        return;
                      }
                      ref
                          .read(inboundPageVMProvider.notifier)
                          .handleScannedData(value);
                      _scannerTextController.clear();
                      if (!ref.read(inboundPageVMProvider).showInboundPopup) {
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
                child: isMissionSelectionMode || isOrderSelectionMode
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (isMissionSelectionMode)
                            ElevatedButton(
                              onPressed:
                                  selectedMissionNos.isEmpty ||
                                      missionState.isDeleting
                                  ? null
                                  : () async {
                                      final success = await ref
                                          .read(
                                            inboundMissionListProvider.notifier,
                                          )
                                          .deleteSelectedInboundMissions();
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
                                        ref
                                            .read(
                                              inboundMissionListProvider
                                                  .notifier,
                                            )
                                            .disableSelectionMode();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: missionState.isDeleting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      '미션 삭제 (${selectedMissionNos.length})',
                                    ),
                            ),
                          if (isOrderSelectionMode)
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(inboundOrderListProvider.notifier)
                                    .deleteSelectedOrders();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                '요청 항목 삭제 (${selectedOrderPltNos.length})',
                              ),
                            ),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(inboundMissionListProvider.notifier)
                                  .disableSelectionMode();
                              ref
                                  .read(inboundOrderListProvider.notifier)
                                  .disableSelectionMode();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              foregroundColor: Colors.white,
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
                            ),
                            child: const Text('삭제'),
                          ),
                          ElevatedButton(
                            onPressed:
                                orderState.orders.isEmpty ||
                                    orderState.isLoading
                                ? null
                                : () async {
                                    try {
                                      final count = await ref
                                          .read(
                                            inboundOrderListProvider.notifier,
                                          )
                                          .requestInboundWork();
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: const Text('성공'),
                                            content: Text(
                                              '$count건의 작업이 성공적으로 요청되었습니다.',
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
                                    } catch (e) {
                                      if (!context.mounted) return;
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext dialogContext) {
                                          return AlertDialog(
                                            title: const Text('실패'),
                                            content: Text(
                                              e.toString().replaceFirst(
                                                'Exception: ',
                                                '',
                                              ),
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
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.celltrionGreen,
                              foregroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(' 작업 시작 '),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _scannerFocusNode.unfocus();
                              ref
                                  .read(inboundPageVMProvider.notifier)
                                  .setInboundPopupState(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade500,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('생성'),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 4),
              if (inboundOrderItems.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
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
                        "입고 요청 List (${inboundOrderItems.length}건)",
                        style: TextStyle(
                          color: AppColors.celltrionBlack,
                          fontWeight: FontWeight.bold,
                        ),
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
                        columns: const [
                          DataColumn(label: Text('PLT No.')),
                          DataColumn(label: Text('제품랙단수')),
                          DataColumn(label: Text('요청시간')),
                        ],
                        rows: inboundOrderItems.map((item) {
                          DataCell buildTappableCellForRegistration(
                            Widget child,
                          ) {
                            return DataCell(
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onLongPress: () {
                                  ref
                                      .read(inboundOrderListProvider.notifier)
                                      .toggleOrderSelection(item.pltNo);
                                },
                                onTap: () {
                                  if (isOrderSelectionMode) {
                                    ref
                                        .read(inboundOrderListProvider.notifier)
                                        .toggleOrderSelection(item.pltNo);
                                  }
                                },
                                child: child,
                              ),
                            );
                          }

                          return DataRow(
                            selected: selectedOrderPltNos.contains(item.pltNo),
                            onSelectChanged: isOrderSelectionMode
                                ? (isSelected) {
                                    ref
                                        .read(inboundOrderListProvider.notifier)
                                        .toggleOrderSelection(item.pltNo);
                                  }
                                : null,
                            cells: [
                              buildTappableCellForRegistration(
                                Text(item.pltNo),
                              ),
                              buildTappableCellForRegistration(
                                Text(item.selectedRackLevel),
                              ),
                              buildTappableCellForRegistration(
                                Text(formatter.format(item.workStartTime)),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
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
                            fieldValue: selectedMission?.pltNo.toString(),
                          ),
                          InfoFieldWidget(
                            fieldName: '제품',
                            fieldValue: selectedMission != null
                                ? "${selectedMission.targetRackLevel.toString()}단 - 00${selectedMission.targetRackLevel.toString()}"
                                : "-",
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
                            fieldValue: selectedMission?.startTime.toString(),
                          ),
                          InfoFieldWidget(
                            fieldName: '랩핑',
                            fieldValue: selectedMission?.isWrapped.toString(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (isLoadingMissions)
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
                        // DataColumn(label: Text('No.')),
                        DataColumn(label: Text('PltNo.')),
                        DataColumn(label: Text('출발지')),
                        DataColumn(label: Text('목적지')),
                      ],
                      rows: inboundMissions.map((mission) {
                        DataCell buildTappableCell(Widget child) {
                          return DataCell(
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onLongPress: () {
                                ref
                                    .read(inboundMissionListProvider.notifier)
                                    .enableSelectionMode(mission.missionNo);
                              },
                              onTap: () {
                                if (isMissionSelectionMode) {
                                  ref
                                      .read(inboundMissionListProvider.notifier)
                                      .toggleMissionForDeletion(
                                        mission.missionNo,
                                      );
                                } else {
                                  ref
                                      .read(inboundMissionListProvider.notifier)
                                      .selectMission(mission);
                                }
                              },
                              child: child,
                            ),
                          );
                        }

                        return DataRow(
                          selected:
                              isMissionSelectionMode &&
                              selectedMissionNos.contains(mission.missionNo),
                          onSelectChanged: isMissionSelectionMode
                              ? (isSelected) {
                                  ref
                                      .read(inboundMissionListProvider.notifier)
                                      .toggleMissionForDeletion(
                                        mission.missionNo,
                                      );
                                }
                              : null,
                          cells: [
                            // buildTappableCell(Text(mission.missionNo.toString())),
                            buildTappableCell(Text(mission.pltNo)),
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
