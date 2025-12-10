import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/features/status/presentation/status_page_vm.dart';

class StatusPage extends ConsumerWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✨ [수정] VM을 통해 데이터 접근
    final statusState = ref.watch(statusPageVMProvider);
    final inboundPoList = statusState.inboundPoList;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // 2. 메인 컨텐츠 (스크롤 가능)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // --- [섹션 1] Device Status ---
                  // 🗑️ "Device Status" 헤더 삭제함

                  // ✨ [수정됨] 카드형 UI (패딩 및 사이즈 조절)
                  _buildDeviceStatusRow(context),

                  const SizedBox(height: 32), // 섹션 간 간격
                  // --- [섹션 2] Order Status ---
                  _buildCustomSectionHeader(
                    title: 'Order Status',
                    icon: Icons.list_alt,
                  ),
                  const SizedBox(height: 12),

                  // 1) 입고 테이블 ✨ [수정] PO 데이터 사용
                  _buildSubHeader('입고', const Color(0xFF8BC34A)),
                  _buildTable(
                    columns: ['HuId', '출발지', '목적구역', '제품규격/단수'],
                    rows: inboundPoList.map((po) {
                      return [
                        po.huId ?? '-', // null 처리
                        po.sourceBin,
                        po.destinationArea == 0 ? '지정구역' : '랙', // Enum or string based on entity
                        '${po.targetRackLevel}단', // Adjust based on actual entity field for "제품규격/단수"
                      ];
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 2) 출고 테이블
                  _buildSubHeader('출고', const Color(0xFFFFC107)),
                  _buildTable(
                    columns: ['DO / 저장빈 No'],
                    rows: [
                      ['801088817'],
                      ['801088817'],
                      ['2A20-11-10-01'],
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3) 1층 출고 테이블
                  _buildSubHeader('1층출고', const Color(0xFF03A9F4)),
                  _buildTable(
                    columns: ['출발구역', '목적구역', '수량', '예약시간'],
                    columnWidths: {
                      0: const FlexColumnWidth(1.2),
                      1: const FlexColumnWidth(1.2),
                      2: const FlexColumnWidth(0.6),
                      3: const FlexColumnWidth(1.5),
                    },
                    rows: [
                      ['2A20-AMR-01', '2A10-AMR-02', '20', '2025-12-0318:00'],
                      ['2A20-12', '2A10-AMR-02', '5', '2025-12-0319:00'],
                      ['2A20-11', '2A10-AMR-01', '8', '2025-12-0320:00'],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Widgets ---

  Widget _buildCustomSectionHeader({
    required String title,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.celltrionGreen),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.celltrionBlack,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Divider(height: 1, thickness: 2, color: AppColors.celltrionGreen),
      ],
    );
  }

  Widget _buildSubHeader(String title, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDeviceStatusRow(BuildContext context) {
    final devices = [
      {'name': '메인 E/V', 'status': true},
      {'name': '보조 E/V', 'status': false},
    ];

    return Row(
      children: devices.map((device) {
        final name = device['name'] as String;
        final isNormal = device['status'] as bool;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildDeviceCard(context, name, isNormal),
          ),
        );
      }).toList(),
    );
  }

  // ✨ [수정됨] 패딩 축소 및 오버플로우 방지 처리
  // ✨ [절충안] 디자인은 '이전 버전' + 높이는 '컴팩트'
  Widget _buildDeviceCard(BuildContext context, String name, bool isNormal) {
    // 1. UI 복구 (이전의 명확한 색상과 텍스트)
    final statusColor = isNormal
        ? const Color(0xFF4CAF50)
        : const Color(0xFFF44336);
    final backgroundColor = isNormal
        ? const Color(0xFFE8F5E9)
        : const Color(0xFFFFEBEE);
    final statusText = isNormal ? "정상 가동" : "점검/고장"; // 텍스트 복구
    final buttonText = isNormal ? "🚨 고장 신고" : "✅ 수리 완료"; // 텍스트 복구

    return Container(
      // 패딩: 6(너무 좁음)과 12(너무 넓음)의 중간인 8 적용
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 높이 최소화
        children: [
          // 1. 헤더 (이름 + 뱃지)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12, // 가독성 확보
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9, // 뱃지는 작게 유지
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8), // 간격 적당히 유지
          // 2. 액션 버튼 (높이만 컴팩트하게 조절)
          SizedBox(
            width: double.infinity,
            height: 28, // ✨ 높이의 핵심: 36 -> 28로 줄임
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: statusColor,
                side: BorderSide(color: statusColor),
                elevation: 0,
                padding: EdgeInsets.zero,
                // 내부 패딩 제거
                // 버튼의 불필요한 마진 제거 (높이 절약)
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () =>
                  _showChangeStatusDialog(context, name, !isNormal),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11, // 텍스트 사이즈는 유지하여 가독성 확보
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
          title: Text(toStatus ? "수리 완료 처리" : "고장 신고"),
          content: Text(
            "$deviceName 의 상태를\n'${toStatus ? "정상" : "고장"}'(으)로 변경하시겠습니까?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("취소", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: toStatus
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFF44336),
              ),
              onPressed: () {
                // TODO: API Call
                Navigator.of(ctx).pop();
              },
              child: const Text("확인", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTable({
    required List<String> columns,
    required List<List<String>> rows,
    Map<int, TableColumnWidth>? columnWidths,
  }) {
    // (테이블 코드는 기존과 동일)
    return Table(
      border: const TableBorder(
        left: BorderSide(color: Colors.black),
        right: BorderSide(color: Colors.black),
        bottom: BorderSide(color: Colors.black),
        horizontalInside: BorderSide(color: Colors.black),
        verticalInside: BorderSide(color: Colors.black),
      ),
      columnWidths: columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Colors.white),
          children: columns
              .map(
                (col) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 4,
                  ),
                  child: Text(
                    col,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
        ...rows.map(
          (row) => TableRow(
            children: row
                .map(
                  (cell) => Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    child: Text(
                      cell,
                      style: const TextStyle(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

