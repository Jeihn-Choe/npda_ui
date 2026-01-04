import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/features/status/presentation/status_page_vm.dart';

class StatusPage extends ConsumerWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusState = ref.watch(statusPageVMProvider);
    final inboundPoList = statusState.inboundPoList;
    final outboundPoList = statusState.outboundPoList;
    // final outbound1FPoList = statusState.outbound1FPoList; // 사용 시 주석 해제

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.90,
      backgroundColor: AppColors.grey100, // ✨ 전체 배경색 변경
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // --- [섹션 1] Device Status ---

                  // 카드형 장비 상태 위젯 (ViewModel 상태 반영)
                  _buildDeviceStatusRow(context, statusState),

                  // --- [섹션 2] Order Status ---
                  const SizedBox(height: 20),

                  // 1) 입고 테이블
                  _buildSubHeader('입고 (Inbound)', AppColors.celltrionGreen),
                  // ✨ 새 서브 헤더 위젯 사용
                  const SizedBox(height: 8),
                  _buildStyledTable(
                    // ✨ 스타일링된 테이블 위젯 사용
                    columns: ['HuId', '출발지', '', ''],
                    columnWidths: {
                      0: const FlexColumnWidth(1.4), // HuId 넓게
                      1: const FlexColumnWidth(1.8), // 출발지 넓게
                      2: const FlexColumnWidth(0.8), // 목적구역 (헤더 없음)
                      3: const FlexColumnWidth(0.6), // 단 (헤더 없음)
                    },
                    rows: inboundPoList.map((po) {
                      return [
                        po.huId ?? '-',
                        po.sourceBin,
                        po.destinationArea == 0 ? '지정구역' : '랙',
                        '${po.targetRackLevel}단',
                      ];
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // 2) 출고 테이블
                  _buildSubHeader('출고 (Outbound)', AppColors.orange),
                  // ✨ 새 서브 헤더 위젯 사용
                  const SizedBox(height: 8),
                  _buildStyledTable(
                    columns: ['DO No', '저장빈 No'],
                    // columnWidths: {
                    //   0: const FlexColumnWidth(1.4), // HuId 넓게
                    //   1: const FlexColumnWidth(1.8), // 출발지 넓게
                    // },
                    rows: outboundPoList.map((po) {
                      return [
                        po.doNo.isNotEmpty ? po.doNo : '',
                        po.sourceBin.isNotEmpty ? po.sourceBin : '',
                      ];
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 3) 1층 출고 테이블
                  _buildSubHeader('1층 출고 (1F Outbound)', AppColors.purple),
                  // ✨ 새 서브 헤더 위젯 사용, 색상 변경
                  const SizedBox(height: 8),
                  _buildStyledTable(
                    // ✨ 스타일링된 테이블 위젯 사용
                    columns: ['출발구역', '목적구역', '수량', '예약시간'],
                    columnWidths: {
                      0: const FlexColumnWidth(1.2),
                      1: const FlexColumnWidth(1.2),
                      2: const FlexColumnWidth(0.6),
                      3: const FlexColumnWidth(1.5),
                    },
                    // TODO: ViewModel 데이터 연동 시 교체
                    rows: [
                      ['2A20-AMR-01', '2A10-AMR-02', '20', '12-03 18:00'],
                      ['2A20-12', '2A10-AMR-02', '5', '12-03 19:00'],
                      ['2A20-11', '2A10-AMR-01', '8', '12-03 20:00'],
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  // ✨ [추가] 서브 헤더 (왼쪽 라인 포인트 개선된 디자인)
  Widget _buildSubHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.grey700,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceStatusRow(BuildContext context, StatusState state) {
    final devices = [
      {'name': '메인 E/V', 'status': state.isMainLiftAvailable},
      {'name': '보조 E/V', 'status': state.isSubLiftAvailable},
    ];

    return Row(
      children: devices.map((device) {
        final name = device['name'] as String;
        final isNormal = device['status'] as bool;
        // ✨ [수정] 원본의 horizontal padding 유지
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildDeviceCard(context, name, isNormal),
          ),
        );
      }).toList(),
    );
  }

  // ✨ [UI 개선] 카드형 장비 상태 위젯 (원본 크기 유지)
  Widget _buildDeviceCard(BuildContext context, String name, bool isNormal) {
    final statusColor = isNormal
        ? AppColors.success
        : AppColors.error; // ✨ AppColors 사용
    final buttonText = isNormal ? "고장 신고" : "수리 완료";

    return Container(
      padding: const EdgeInsets.all(8), // ✨ 원본 패딩 유지
      decoration: BoxDecoration(
        color: Colors.white, // ✨ 배경색 흰색으로 변경
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          // ✨ 그림자 효과 추가
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isNormal ? Colors.transparent : statusColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // ✨ 높이 최소화 유지
        crossAxisAlignment: CrossAxisAlignment.start, // ✨ 왼쪽 정렬
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                // ✨ Expanded로 텍스트 공간 확보
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // ✨ 폰트 사이즈 키움
                    color: AppColors.celltrionBlack, // ✨ AppColors 사용
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // ✨ [수정] 아이콘 대신 텍스트(정상/고장) 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isNormal ? '정상' : '고장',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12), // ✨ 간격 조정
          SizedBox(
            width: double.infinity,
            height: 28, // ✨ 원본 버튼 높이 유지
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                // ✨ AppColors 사용
                foregroundColor: statusColor,
                elevation: 0,
                side: BorderSide(color: statusColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  // ✨ 테두리 둥글게
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () =>
                  _showChangeStatusDialog(context, name, !isNormal),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // ✨ 폰트 사이즈 키움
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangeStatusDialog(
    BuildContext context,
    String deviceName,
    bool toStatus,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            toStatus ? "수리 완료 처리" : "고장 신고",
            style: const TextStyle(fontWeight: FontWeight.bold), // ✨ 폰트 굵게
          ),
          content: Text(
            "$deviceName 의 상태를\n'${toStatus ? "정상" : "고장"}'(으)로 변경하시겠습니까?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                "취소",
                style: TextStyle(color: AppColors.grey600),
              ), // ✨ AppColors 사용
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: toStatus
                    ? AppColors.success
                    : AppColors.error, // ✨ AppColors 사용
              ),
              onPressed: () {
                // 🚀 [수정] ViewModel의 상태 변경 메서드 호출
                ref
                    .read(statusPageVMProvider.notifier)
                    .changeEvStatus(deviceName, toStatus);
                Navigator.of(ctx).pop();
              },
              child: const Text("확인", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ✨ [추가] 스타일이 적용된 테이블
  Widget _buildStyledTable({
    required List<String> columns,
    required List<List<String>> rows,
    Map<int, TableColumnWidth>? columnWidths,
  }) {
    if (rows.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.grey300),
        ),
        child: const Center(
          child: Text(
            "데이터가 없습니다.",
            style: TextStyle(color: AppColors.grey500, fontSize: 12),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.grey300),
        ),
        child: Table(
          columnWidths: columnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: const TableBorder(
            horizontalInside: BorderSide(color: AppColors.grey200),
          ),
          children: [
            // Header Row
            TableRow(
              decoration: const BoxDecoration(color: AppColors.grey100),
              children: columns
                  .map(
                    (col) => Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 8,
                      ),
                      child: Text(
                        col,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.grey800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                  .toList(),
            ),
            // Data Rows
            ...rows.map(
              (row) => TableRow(
                children: row
                    .map(
                      (cell) => Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 8,
                        ),
                        child: Text(
                          cell,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.celltrionBlack,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
