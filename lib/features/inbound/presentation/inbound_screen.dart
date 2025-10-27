import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/inbound_viewmodel.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup.dart';
import 'package:npda_ui_flutter/presentation/widgets/form_card_layout.dart';
import 'package:npda_ui_flutter/presentation/widgets/info_field_widget.dart';

import '../../../presentation/main_shell.dart';
import '../../../core/state/session_manager.dart';

class InboundScreen extends ConsumerStatefulWidget {
  const InboundScreen({super.key});

  @override
  ConsumerState<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends ConsumerState<InboundScreen> {
  late FocusNode _scannerFocusNode; // 스캐너 입력용 FocusNode
  late TextEditingController _scannerTextController;

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
    // 🚀 추가된 부분: 로그인 상태가 아닐 경우, 포커스 로직을 실행하지 않음
    final sessionStatus = ref.read(sessionManagerProvider).status;
    if (sessionStatus != SessionStatus.loggedIn) return;

    final currentTabIndex = ref.read(mainShellTabIndexProvider); // modified
    if (currentTabIndex != 0) return; // 인바운드 탭이 아닐때는 포커스 로직 무시

    final inboundState = ref.read(inboundViewModelProvider);

    if (!inboundState.showInboundPopup && !_scannerFocusNode.hasFocus) {
      // modified
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

    // ✨ 추가될 부분
    // '입고 요청 List'의 선택 모드 활성화 여부
    final isRegistrationSelectionModeActive =
        inboundResgistrationSelectedItems.isNotEmpty;

    /// viewmodel 상태 구독
    final inboundState = ref.watch(inboundViewModelProvider);

    /// Viwemodel에서 정의한 상태에서 필요한 값 추출
    final inboundMissions = inboundState.inboundMissions;
    final getCurrentMissionsIsLoading = inboundState.isLoading;
    final getCurrentMissionsErrorMessage = inboundState.errorMessage;
    final selectedMissionNos = inboundState.selectedMissionNos;
    final selectedMission = inboundState.selectedMission;
    final isSelectionModeActive = inboundState.isSelectionModeActive;
    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    /// inboundViewModel의 팝업 상태(scanned 여부가 들어옴) 변화 감지 후 팝업 띄움
    ref.listen<InboundMissionState>(inboundViewModelProvider, (previous, next) {
      if (next.showInboundPopup && !previous!.showInboundPopup) {
        // 팝업이 뜬다면 포커스를 없애줘야 popup의 텍스트필드에 포커스가 갈수있음.
        _scannerFocusNode.unfocus();

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
            ref
                .read(inboundViewModelProvider.notifier)
                .setInboundPopupState(false);

            ref.read(inboundRegistrationPopupViewModelProvider).resetForm();

            ref.read(inboundViewModelProvider.notifier).clearInboundPopup();
            ref.invalidate(inboundRegistrationPopupViewModelProvider);
            FocusScope.of(context).requestFocus(_scannerFocusNode);
            logger("팝업 닫힘 - 포커스 다시 가져옴");
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
                    enabled: !inboundState.showInboundPopup,
                    onSubmitted: (value) {
                      final inboundState = ref.read(inboundViewModelProvider);
                      if (inboundState.showInboundPopup) {
                        logger("팝업이 떠있는 상태에서 스캔 입력이 들어왔습니다. 무시합니다.");
                        _scannerTextController.clear();
                        return;
                      }
                      logger("인바운드 화면 스캐너 입력 감지 : $value");
                      // viewmodel에 스캔된 데이터 전달
                      ref
                          .read(inboundViewModelProvider.notifier)
                          .handleScannedData(value);
                      // 텍스트필드 초기화
                      _scannerTextController.clear();
                      logger("텍스트필드 초기화");

                      /// 스캔 모드가 활성화되어있지 않고, 팝업이 떠 있지 않다면 포커스를 다시 요청해서 스캐너 입력을 받을 수 있도록 해야함.
                      // final isScannerModeActive = ref.read(
                      //   scannerViewModelProvider,
                      // );

                      if (!inboundState.showInboundPopup) {
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

                // ✨ 변경된 부분 --- 시작
                /// Mission 선택 모드 또는 입고 요청 List 선택 모드 둘 중 하나라도 활성화되면 선택 버튼 바를 표시
                child: isSelectionModeActive || isRegistrationSelectionModeActive
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Mission 선택 모드일 때 '미션 삭제' 버튼 표시
                          if (isSelectionModeActive)
                            ElevatedButton(
                              onPressed:
                                  selectedMissionNos.isEmpty ||
                                          inboundState.isDeleting
                                      ? null
                                      : () async {
                                          final success = await ref
                                              .read(inboundViewModelProvider
                                                  .notifier)
                                              .deleteSelectedInboundMissions();

                                          if (!context.mounted) return;

                                          showDialog(
                                            context: context,
                                            builder:
                                                (BuildContext dialogContext) {
                                              return AlertDialog(
                                                title:
                                                    Text(success ? '성공' : '실패'),
                                                content: Text(
                                                  success
                                                      ? '선택된 미션이 삭제되었습니다.'
                                                      : '미션 삭제에 실패했습니다.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                              dialogContext)
                                                            .pop(),
                                                    child: const Text('확인'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (success) {
                                            ref
                                                .read(inboundViewModelProvider
                                                    .notifier)
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
                              child: inboundState.isDeleting
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      '미션 삭제 (${selectedMissionNos.length})',
                                    ),
                            ),

                          // 입고 요청 List 선택 모드일 때 '요청 항목 삭제' 버튼 표시
                          if (isRegistrationSelectionModeActive)
                            ElevatedButton(
                              onPressed: () {
                                ref
                                    .read(inboundRegistrationListProvider
                                        .notifier)
                                    .deletedSelectionItems();
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
                                '요청 항목 삭제 (${inboundResgistrationSelectedItems.length})',
                              ),
                            ),

                          // 통합된 '취소' 버튼
                          ElevatedButton(
                            onPressed: () {
                              // 두 Notifier의 선택 모드를 모두 해제
                              ref
                                  .read(inboundViewModelProvider.notifier)
                                  .disableSelectionMode();
                              ref
                                  .read(inboundRegistrationListProvider
                                      .notifier)
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
                                                  onPressed: () =>
                                                      Navigator.of(
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
                              _scannerFocusNode.unfocus();
                              ref
                                  .read(inboundViewModelProvider.notifier)
                                  .setInboundPopupState(true);
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
                          /// '입고 요청 List'의 각 셀을 감싸는 GestureDetector 위젯 생성 헬퍼 함수
                          DataCell buildTappableCellForRegistration(Widget child) {
                            return DataCell(
                              GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                // ✨ 변경된 부분: 길게 눌러서 선택 모드 시작
                                onLongPress: () {
                                  ref.read(inboundRegistrationListProvider.notifier).toggleItemSelection(item.pltNo);
                                },
                                // 탭 이벤트는 onSelectChanged가 처리하므로 여기서는 비워둠
                                onTap: () {
                                   // 선택 모드일 때만 탭으로 토글 가능
                                  if (isRegistrationSelectionModeActive) {
                                     ref.read(inboundRegistrationListProvider.notifier).toggleItemSelection(item.pltNo);
                                  }
                                },
                                child: child,
                              ),
                            );
                          }

                          return DataRow(
                            // ✨ 변경된 부분 --- 시작
                            selected: inboundResgistrationSelectedItems.contains(item.pltNo),
                            // 선택 모드가 활성화되었을 때만 onSelectChanged를 설정하여 체크박스 표시
                            onSelectChanged: isRegistrationSelectionModeActive
                                ? (isSelected) {
                                    ref.read(inboundRegistrationListProvider.notifier).toggleItemSelection(item.pltNo);
                                  }
                                : null, // null이면 체크박스가 보이지 않음
                            // ✨ 변경된 부분 --- 끝
                            cells: [
                              buildTappableCellForRegistration(Text(item.pltNo)),
                              buildTappableCellForRegistration(Text(item.selectedRackLevel)),
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

                      rows: inboundMissions.map((mission) {
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
}
