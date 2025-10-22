import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/popups/outbound_popup.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_mission_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_order_list_provider.dart';

import '../../../core/constants/colors.dart';
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

    // 포커스 변경 감지 리스너 추가 => 포커스를 invisible에서 잃으면 다시 갖다놔야함.
    _scannerFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final currentTabIndex = ref.read(mainShellTabIndexProvider); // modified
    if (currentTabIndex != 1) return; // 아웃바운드 화면이 아닐때는 무시

    final outboundState = ref.read(outboundScreenViewModelProvider);
    if (!_scannerFocusNode.hasFocus && !outboundState.showOutboundPopup) {
      FocusScope.of(context).requestFocus(_scannerFocusNode);
      appLogger.d("포커스 다시 가져옴");
    }
  }

  @override
  void dispose() {
    // 컨트롤러와 포커스 노드의 리소스를 해제합니다.
    _scannerFocusNode.removeListener(_onFocusChange);
    _scannerFocusNode.dispose();
    _scannerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outboundState = ref.watch(outboundScreenViewModelProvider);
    final orderListState = ref.watch(outboundOrderListProvider);

    // viewmodel 의 팝업 상태 감지
    ref.listen<OutboundScreenState>(outboundScreenViewModelProvider, (
      previous,
      next,
    ) {
      /// ShowOutboundPopup 상태가 true로 변경되면 popup을 띄움움
      if (next.showOutboundPopup && previous?.showOutboundPopup == false) {
        /// 팝업 띄우기 전 스캐너 포커스 해제
        _scannerFocusNode.unfocus();

        showDialog(
          context: context,
          barrierDismissible: false, // 바깥 영역 터치시 닫히지 않도록 설정
          builder: (BuildContext dialogContext) {
            return OutboundPopup(scannedData: next.scannedDataForPopup);
          },
        ).then((_) {
          // 팝업이 닫히고 나서 포커스 다시 가져오기
          if (mounted) {
            /// 1. viewmodel 에 팝업 닫힘 상태 전달
            ref
                .read(outboundScreenViewModelProvider.notifier)
                .closeCreationPopup(false);

            /// 2. 포커스 다시 가져오기
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
              /// 보이지 않는 스캐너 입력용 TextField
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
                      final outboundState = ref.read(
                        outboundScreenViewModelProvider,
                      );
                      if (outboundState.showOutboundPopup) {
                        appLogger.d("팝업이 떠있는 상태에서 스캔 입력이 들어왔습니다. 무시합니다.");
                        _scannerTextController.clear();
                        return;
                      }
                      appLogger.d("아웃바운드 화면 스캐너 입력 감지 : $value");
                      // viewmodel에 스캔된 데이터 전달
                      ref
                          .read(outboundScreenViewModelProvider.notifier)
                          .handleScannedData(value);
                      // 텍스트필드 초기화
                      _scannerTextController.clear();
                      appLogger.d("텍스트필드 초기화");

                      /// 스캔 모드가 활성화되어있지 않고, 팝업이 떠 있지 않다면 포커스를 다시 요청해서 스캐너 입력을 받을 수 있도록 해야함.
                      // final isScannerModeActive = ref.read(
                      //   scannerViewModelProvider,
                      // );

                      if (!outboundState.showOutboundPopup) {
                        FocusScope.of(context).requestFocus(_scannerFocusNode);
                        logger("포커스 다시 가져옴");
                      }
                    },
                  ),
                ),
              ),

              /// 상단 버튼 바
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),

                /// 선택모드 활성화 --> 삭제, 취소 버튼 표시.
                child: outboundState.isMissionSelectionModeActive
                    ?
                      // 1. 미션 선택 모드일 때의 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                outboundState.selectedMissionNos.isEmpty ||
                                    outboundState.isMissionDeleting
                                ? null
                                : () async {
                                    final success =
                                        await ref // modified
                                            .read(
                                              outboundScreenViewModelProvider
                                                  .notifier,
                                            )
                                            .deleteSelectedOutboundMissions();

                                    if (!context.mounted) return; // modified

                                    showDialog(
                                      // modified
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
                                      // modified
                                      ref
                                          .read(
                                            outboundScreenViewModelProvider
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
                                outboundState
                                    .isMissionDeleting // modified
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    '선택 항목 삭제 (${outboundState.selectedMissionNos.length})',
                                  ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(
                                    outboundScreenViewModelProvider.notifier,
                                  )
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
                    : outboundState.isOrderSelectionModeActive
                    ?
                      // 2. 주문 선택 모드일 때의 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                outboundState.selectedOrderNos.isEmpty ||
                                    outboundState.isOrderDeleting
                                ? null
                                : () async {
                                    // 주문 삭제 메서드 호출
                                    await ref
                                        .read(
                                          outboundScreenViewModelProvider
                                              .notifier,
                                        )
                                        .deleteSelectedOutboundOrders();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: outboundState.isOrderDeleting
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    '선택 항목 삭제 (${outboundState.selectedOrderNos.length})',
                                  ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // 주문 선택 모드 비활성화
                              ref
                                  .read(
                                    outboundScreenViewModelProvider.notifier,
                                  )
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
                    :
                      // 3. 기본 상태일 때의 버튼
                      Row(
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

              /// inboundRegistrationList 생성 시 해당 정보 표시 - 평소에는 존재 x
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
                            outboundState.isOrderSelectionModeActive,
                        columns: const [
                          DataColumn(label: Text('DO No / 저장빈 No.')),
                          DataColumn(label: Text('요청시간')),
                        ],
                        rows: orderListState.orders.map((order) {
                          return DataRow(
                            selected:
                                outboundState.isOrderSelectionModeActive &&
                                outboundState.selectedOrderNos.contains(
                                  order.orderNo,
                                ),
                            onSelectChanged: (isSelected) {
                              if (outboundState.isOrderSelectionModeActive) {
                                ref
                                    .read(
                                      outboundScreenViewModelProvider.notifier,
                                    )
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
                                          outboundScreenViewModelProvider
                                              .notifier,
                                        )
                                        .enableOrderSelectionMode(
                                          order.orderNo,
                                        );
                                  },
                                  onTap: () {
                                    if (outboundState
                                        .isOrderSelectionModeActive) {
                                      ref
                                          .read(
                                            outboundScreenViewModelProvider
                                                .notifier,
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
                                          outboundScreenViewModelProvider
                                              .notifier,
                                        )
                                        .enableOrderSelectionMode(
                                          order.orderNo,
                                        );
                                  },
                                  onTap: () {
                                    if (outboundState
                                        .isOrderSelectionModeActive) {
                                      ref
                                          .read(
                                            outboundScreenViewModelProvider
                                                .notifier,
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

              /// 중앙 오더 상세 표시
              FormCardLayout(
                contentPadding: 12,
                verticalMargin: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// 하단의 리스트에서 선택된 행 표시, null 이면 빈칸
                    Expanded(
                      child: Column(
                        children: [
                          InfoFieldWidget(
                            fieldName: 'No.',
                            fieldValue: outboundState.selectedMission?.doNo
                                .toString(),
                          ),
                          InfoFieldWidget(
                            fieldName: '출발지',
                            fieldValue:
                                outboundState.selectedMission?.sourceBin,
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
                            fieldValue: outboundState.selectedMission?.startTime
                                .toString(),
                          ),
                          InfoFieldWidget(
                            fieldName: '목적지',
                            fieldValue: outboundState
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

              /// 하단 데이터그리드
              if (outboundState.isMissionListLoading)
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

                      rows: ref.watch(outboundMissionListProvider).missions.map(
                        (mission) {
                          /// 각 셀을 감싸는 GestureDetector 위젯 생성 헬퍼 함수
                          /// onTap, onLongPress 이벤트 핸들러 추가해야함.
                          DataCell buildTappableCell(Widget child) {
                            return DataCell(
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onLongPress: () {
                                  ref
                                      .read(
                                        outboundScreenViewModelProvider
                                            .notifier,
                                      )
                                      .enableSelectionMode(mission.missionNo);
                                },
                                onTap: () {
                                  if (outboundState
                                      .isMissionSelectionModeActive) {
                                    ref
                                        .read(
                                          outboundScreenViewModelProvider
                                              .notifier,
                                        )
                                        .toggleMissionForDeletion(
                                          mission.missionNo,
                                        );
                                  } else {
                                    ref
                                        .read(
                                          outboundScreenViewModelProvider
                                              .notifier,
                                        )
                                        .selectMission(mission);
                                  }
                                },
                                child: child,
                              ),
                            );
                          }

                          return DataRow(
                            /// 선택모드 UI 로직
                            /// isSelectionModeActive true --> 체크박스 표시 o
                            /// isSelectionModeActive false --> 체크박스 표시 x
                            /// 선택모드가 활성화된 상태에서 행을 탭하면 해당 행이 선택/선택해제 토글됨.
                            selected:
                                outboundState.isMissionSelectionModeActive &&
                                outboundState.selectedMissionNos.contains(
                                  mission.missionNo,
                                ),

                            onSelectChanged:
                                outboundState.isMissionSelectionModeActive
                                ? (isSelected) {
                                    ref
                                        .read(
                                          outboundScreenViewModelProvider
                                              .notifier,
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
                                Text(
                                  mission?.doNo ?? mission?.sourceBin ?? "-",
                                ),
                              ),
                              buildTappableCell(Text(mission.sourceBin)),
                              buildTappableCell(Text(mission.destinationBin)),
                            ],
                          );
                        },
                      ).toList(),
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
