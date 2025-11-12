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
import 'package:npda_ui_flutter/presentation/widgets/robot_button.dart';

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

  /// 2025-11-12 최제인
  /// ======= 포커스 강제로직 = 무작위 스캔이벤트를 받을 수 있도록 하는 상태로 만드는 로직 =======
  /// 발동조건
  /// - 세션 로그인 상태
  /// - 메인탭이 인바운드 탭일때
  /// - 입고 : HU Id 스캔 && 출발지 저장빈 스캔 --> 둘 다 만족하는 경우
  /// 해제하려면
  void _onFocusChange() {
    final sessionStatus = ref.read(sessionManagerProvider).status;
    if (sessionStatus != SessionStatus.loggedIn) return;

    final currentTabIndex = ref.read(mainShellTabIndexProvider);
    if (currentTabIndex != 0) return;

    final pageState = ref.read(inboundPageVMProvider);

    // 팝업이 열려있으면 두 필드가 모두 채워졌는지 확인
    if (pageState.showInboundPopup) {
      final popupViewModel = ref.read(inboundRegistrationPopupViewModelProvider);

      // 두 필드가 모두 채워지면 포커스를 주지 않음 (사용자가 팝업 수정 가능)
      if (popupViewModel.areBothFieldsFilled()) {
        return;
      }

      // 아직 하나라도 비어있으면 포커스 유지 (스캔 대기)
      if (!_scannerFocusNode.hasFocus) {
        FocusScope.of(context).requestFocus(_scannerFocusNode);
      }
      return;
    }

    // 팝업이 닫혀있으면 포커스 유지
    if (!_scannerFocusNode.hasFocus) {
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
      // 팝업 오픈
      if (next.showInboundPopup && (previous?.showInboundPopup == false)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return MediaQuery(
              data: MediaQuery.of(
                dialogContext,
              ).copyWith(viewInsets: EdgeInsets.zero),
              child: InboundRegistrationPopup(
                scannedData: next.firstScannedData,
              ),
            );
          },
        ).then((_) {
          if (mounted) {
            ref.read(inboundPageVMProvider.notifier).clearInboundPopup();
            ref.read(inboundRegistrationPopupViewModelProvider).resetForm();
            ref.invalidate(inboundRegistrationPopupViewModelProvider);
            FocusScope.of(context).requestFocus(_scannerFocusNode);
          }
        });
      }

      // 두 필드가 모두 채워졌을 때 포커스 해제
      if (next.secondScannedData != null &&
          previous?.secondScannedData != next.secondScannedData) {
        _scannerFocusNode.unfocus();
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
                    enabled: true,
                    onSubmitted: (value) {
                      ref
                          .read(inboundPageVMProvider.notifier)
                          .handleScannedData(value);
                      _scannerTextController.clear();
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(' 작업 시작 '),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(inboundPageVMProvider.notifier)
                                  .openPopupManually();
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

              /// ------------ 입고 요청 리스트 --------------
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
                          DataColumn(label: Center(child: Text('HU ID'))),
                          DataColumn(label: Center(child: Text('제품랙단수'))),
                          DataColumn(label: Center(child: Text('최종위치'))),
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
                                Center(child: Text(item.pltNo)),
                              ),
                              buildTappableCellForRegistration(
                                Center(child: Text(item.selectedRackLevel)),
                              ),
                              buildTappableCellForRegistration(
                                Center(child: Text(item.destinationArea ?? '')),
                              ),
                              // buildTappableCellForRegistration(
                              //   Text(formatter.format(item.workStartTime)),
                              // ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              FormCardLayout(
                contentPadding: 8,
                verticalMargin: 2,
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        children: [
                          InfoFieldWidget(
                            fieldName: '시간',
                            fieldValue: selectedMission != null
                                ? selectedMission.startTime.toString().split(
                                    '.',
                                  )[0]
                                : null,
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
              const SizedBox(height: 4),
              Builder(
                builder: (context) {
                  final missionTypeZeroCount = inboundMissions
                      .where((m) => m.missionType == 0)
                      .length;
                  return Column(
                    children: [
                      // 제목과 버튼들을 포함하는 Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 왼쪽: 제목
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                children: <TextSpan>[
                                  const TextSpan(text: '입고 미션 List '),
                                  TextSpan(
                                    text: '(총 $missionTypeZeroCount건)',
                                    style: const TextStyle(
                                      color: AppColors.celltrionGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 오른쪽: 필터 버튼들
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RobotButton(
                                  text: 'Forklift',
                                  backgroundColor: Colors.orange,
                                  onPressed: () {
                                    // TODO: Forklift pause/resume 로직
                                  },
                                ),
                                const SizedBox(width: 4),
                                RobotButton(
                                  text: 'PLT_1F',
                                  backgroundColor: Colors.lightGreen,
                                  onPressed: () {
                                    // TODO: PLT_1F pause/resume 로직
                                  },
                                ),
                                const SizedBox(width: 4),
                                RobotButton(
                                  text: 'PLT_3F',
                                  backgroundColor: Colors.lightBlue,
                                  onPressed: () {
                                    // TODO: PLT_3F pause/resume 로직
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 4),
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
                          color: switch ((
                            mission.subMissionStatus,
                            mission?.robotName,
                          )) {
                            (1, "Forklift") => WidgetStateProperty.all(
                              Colors.orange.shade200,
                            ),
                            (1, "PLTTruck_1F") => WidgetStateProperty.all(
                              Colors.lightGreen.shade200,
                            ),
                            (1, "PLTTruck_3F") => WidgetStateProperty.all(
                              Colors.lightBlue.shade200,
                            ),
                            _ => null,
                          },
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
                            // buildTappableCell(
                            //   Text(mission.robotName.toString()),
                            // ),
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
