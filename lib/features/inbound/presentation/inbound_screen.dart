import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/inbound_viewmodel.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup.dart';
import 'package:npda_ui_flutter/presentation/widgets/form_card_layout.dart';

import '../../../core/state/scanner_viewmodel.dart';

class _InboundItem {
  final int id;
  final String pltNo;
  final String source;
  final String destination;

  _InboundItem({
    required this.id,
    required this.pltNo,
    required this.source,
    required this.destination,
  });
}

class InboundScreen extends ConsumerStatefulWidget {
  const InboundScreen({super.key});

  @override
  ConsumerState<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends ConsumerState<InboundScreen> {
  late FocusNode _scannerFocusNode; // 스캐너 입력용 FocusNode
  late TextEditingController _scannerTextController; // 스캐너 입력용 컨트롤러

  @override
  void initState() {
    super.initState();
    _scannerFocusNode = FocusNode();
    _scannerTextController = TextEditingController();

    // 포커스 변경 감지 리스너 추가 => 포커스를 invisible에서 잃으면 다시 갖다놔야함.
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
    // isScannerModeActive == true 일때만 포커스 유지
    // ref 는 ConsumerState에서 직접 접근 가능.

    final isScannerModeActive = ref.read(scannerViewModelProvider);
    if (isScannerModeActive && !_scannerFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(_scannerFocusNode);
      logger("포커스 다시 가져옴");
    }
  }

  @override
  Widget build(BuildContext context) {
    // inboundRegistrationList 의 상태를 구독해야함.
    // 필요한 상태는 InboundRegistrationListState
    // 그래서 InboundRegistrationListState를 구독해야함.
    final inboundRegistrationList = ref.watch(inboundRegistrationListProvider);

    // 근데 InboundRegistrationListState는 items라는 리스트가있음 => 이게 display 해야 할 데이터임.
    // 그래서 items를 꺼내서 따로 정의해야 ui에서 쓸 수 있음
    final inboundRegistrationListItems = inboundRegistrationList.items;

    // 그리고 ui에서 삭제할 수 있게 selectedItems도 정의해야함
    final inboundResgistrationSelectedItems =
        inboundRegistrationList.selectedPltNos;

    /// viewmodel 상태 구독
    final inboundState = ref.watch(inboundViewModelProvider);

    /// Viwemodel에서 정의한 상태에서 필요한 값 추출
    final currentInboundMissions = inboundState.currentInboundMissions;
    final getCurrentMissionsIsLoading = inboundState.isLoading;
    final getCurrentMissionsErrorMessage = inboundState.errorMessage;
    final selectedMissionNos = inboundState.selectedMissionNos;
    final selectedMission = inboundState.selectedMission;
    final isSelectionModeActive = inboundState.isSelectionModeActive;
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    /// inboundViewModel의 팝업 상태(scanned 여부가 들어옴) 변화 감지 후 팝업 띄움
    ref.listen<CurrentInboundMissionState>(inboundViewModelProvider, (
      previous,
      next,
    ) {
      if (next.showInboundPopup && !previous!.showInboundPopup) {
        // 팝업 띄우기
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return MediaQuery(
              data: MediaQuery.of(
                dialogContext,
              ).copyWith(viewInsets: EdgeInsets.zero),
              child: InboundRegistrationPopup(
                scannedData: next.scannedDataForPopup, // 스캔데이터 팝업에 전달
              ),
            );
          },
        ).then((_) {
          // 팝업 닫힌 후 상태 초기화
          if (mounted) {
            ref.read(inboundViewModelProvider.notifier).clearInboundPopup();
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
                    onSubmitted: (value) {
                      logger("인바운드 화면 스캐너 입력 감지 : $value");
                      // viewmodel에 스캔된 데이터 전달
                      ref
                          .read(inboundViewModelProvider.notifier)
                          .handleScannedData(value);
                      // 텍스트필드 초기화
                      _scannerTextController.clear();
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
                child: isSelectionModeActive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: selectedMissionNos.isEmpty
                                ? null
                                : () {
                                    // TODO : 삭제 로직 구현 필요.
                                    logger("삭제 완료");
                                    // 삭제 후 선택 모드 종료 및 선택된 항목 초기화
                                    ref
                                        .read(inboundViewModelProvider.notifier)
                                        .disableSelectionMode();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                            child: Text(
                              '선택 항목 삭제 (${selectedMissionNos.length})',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(inboundViewModelProvider.notifier)
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
                    /// 선택모드 비활성화 --> 생성, 작업시작 버튼 표시
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
                            // 리스트가 비어있거나, 로딩중일때는 버튼 비활성화
                            onPressed:
                                inboundRegistrationList.items.isEmpty ||
                                    inboundRegistrationList.isLoading
                                ? null
                                : () async {
                                    // Notifier에서 작업 시작 로직 호출
                                    final result = await ref
                                        .read(
                                          inboundRegistrationListProvider
                                              .notifier,
                                        )
                                        .requestInboundWork();

                                    // 결과에 따라 다이얼로그 표시
                                    if (!context.mounted) return;
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return AlertDialog(
                                          title: Text(
                                            result.isSuccess ? '성공' : '실패',
                                          ),
                                          content: Text(
                                            result.msg ??
                                                (result.isSuccess
                                                    ? '작업이 성공적으로 요청되었습니다.'
                                                    : '작업 요청에 실패했습니다.'),
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
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  /// MediaQuery - 키보드 Inset을 무시
                                  return MediaQuery(
                                    data: MediaQuery.of(
                                      dialogContext,
                                    ).copyWith(viewInsets: EdgeInsets.zero),
                                    child: InboundRegistrationPopup(
                                      scannedData: null,
                                    ),
                                  );
                                },
                              );
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
              if (inboundRegistrationListItems.isNotEmpty)
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
                        style: TextStyle(
                          color: AppColors.celltrionBlack,
                          fontWeight: FontWeight.bold,
                        ),
                        "입고 요청 List (${inboundRegistrationListItems.length}건)",
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
                        rows: inboundRegistrationListItems.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(Text(item.pltNo)),
                              DataCell(Text(item.selectedRackLevel)),
                              DataCell(
                                Text(formatter.format(item.workStartTime)),
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
                          _buildInfoField(
                            'No.',
                            selectedMission?.pltNo.toString(),
                          ),
                          _buildInfoField(
                            '제품',
                            selectedMission != null
                                ? "${selectedMission?.targetRackLevel.toString()}단 - 00${selectedMission?.targetRackLevel.toString()}"
                                : "-",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          _buildInfoField(
                            '시간',
                            selectedMission?.startTime.toString(),
                          ),
                          _buildInfoField(
                            '랩핑',
                            selectedMission?.isWrapped.toString(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              /// 하단 데이터그리드
              if (getCurrentMissionsIsLoading)
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

                      rows: currentInboundMissions.map((mission) {
                        /// 각 셀을 감싸는 GestureDetector 위젯 생성 헬퍼 함수
                        /// onTap, onLongPress 이벤트 핸들러 추가해야함.
                        DataCell buildTappableCell(Widget child) {
                          return DataCell(
                            GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onLongPress: () {
                                ref
                                    .read(inboundViewModelProvider.notifier)
                                    .enableSelectionMode(mission.missionNo);
                              },
                              onTap: () {
                                if (isSelectionModeActive) {
                                  ref
                                      .read(inboundViewModelProvider.notifier)
                                      .toggleMissionForDeletion(
                                        mission.missionNo,
                                      );
                                } else {
                                  ref
                                      .read(inboundViewModelProvider.notifier)
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
                              isSelectionModeActive &&
                              selectedMissionNos.contains(mission.missionNo),

                          onSelectChanged: isSelectionModeActive
                              ? (isSelected) {
                                  ref
                                      .read(inboundViewModelProvider.notifier)
                                      .toggleMissionForDeletion(
                                        mission.missionNo,
                                      );
                                }
                              : null,

                          cells: [
                            buildTappableCell(
                              Text(mission.missionNo.toString()),
                            ),
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

  // 정보 필드 UI 헬퍼 메서드
  Widget _buildInfoField(String fieldName, [dynamic? fieldValue]) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$fieldName: ',
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkGrey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.grey100,
            ),
            child: Text(
              fieldValue ?? '-',
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.black,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
