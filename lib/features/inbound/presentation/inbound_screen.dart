import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup.dart';
import 'package:npda_ui_flutter/presentation/widgets/form_card_layout.dart';

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

class InboundScreen extends ConsumerWidget {
  const InboundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    final selectedMisssion = inboundState.selectedMission;

    final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade100,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// 상단 버튼 바
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
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
                                    inboundRegistrationListProvider.notifier,
                                  )
                                  .requestInboundWork();

                              // 결과에 따라 다이얼로그 표시
                              if (!context.mounted) return;
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: Text(result.isSuccess ? '성공' : '실패'),
                                    content: Text(
                                      result.msg ??
                                          (result.isSuccess
                                              ? '작업이 성공적으로 요청되었습니다.'
                                              : '작업 요청에 실패했습니다.'),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(),
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
                              child: InboundRegistrationPopup(),
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
                            selectedMisssion?.pltNo.toString(),
                          ),
                          _buildInfoField(
                            '제품',
                            "${selectedMisssion?.targetRackLevel.toString()}단 - 00${selectedMisssion?.targetRackLevel.toString()}",
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
                            selectedMisssion?.startTime.toString(),
                          ),
                          _buildInfoField(
                            '랩핑',
                            selectedMisssion?.isWrapped.toString(),
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
                const Center(child: CircularProgressIndicator())
              else
                Container(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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

                      rows: currentInboundMissions.map((missions) {
                        return DataRow(
                          //선택 상태 반영
                          selected: selectedMissionNos.contains(
                            missions.missionNo,
                          ),

                          onSelectChanged: (isSelected) {
                            /// 행 선택시 상세 정보 상단에 표시
                            /// notifier에서 행 선택 메서드 호출.
                            ref
                                .read(inboundViewModelProvider.notifier)
                                .selectMission(missions);
                          },

                          cells: [
                            DataCell(Text(missions.missionNo.toString())),
                            DataCell(Text(missions.pltNo)),
                            DataCell(Text(missions.sourceBin)),
                            DataCell(Text(missions.destinationBin)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

              // Container(
              //   child: Container(
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //
              //     child: DataTable(
              //       horizontalMargin: 8,
              //       columnSpacing: 16,
              //       headingRowHeight: 36,
              //       dataRowMinHeight: 36,
              //       dataRowMaxHeight: 36,
              //       headingTextStyle: const TextStyle(
              //         fontSize: 13,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.black,
              //       ),
              //       dataTextStyle: const TextStyle(
              //         fontSize: 12,
              //         color: Colors.black87,
              //       ),
              //       columns: const [
              //         DataColumn(label: Text('No.')),
              //         DataColumn(label: Text('PltNo.')),
              //         DataColumn(label: Text('출발지')),
              //         DataColumn(label: Text('목적지')),
              //       ],
              //       rows: sampleItems.map((item) {
              //         return DataRow(
              //           cells: [
              //             DataCell(Text(item.id.toString())),
              //             DataCell(Text(item.pltNo)),
              //             DataCell(Text(item.source)),
              //             DataCell(Text(item.destination)),
              //           ],
              //         );
              //       }).toList(),
              //     ),
              //   ),
              // ),
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
