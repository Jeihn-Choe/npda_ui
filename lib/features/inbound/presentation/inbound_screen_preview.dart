import 'package:flutter/material.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
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

class InboundScreenPreview extends StatelessWidget {
  const InboundScreenPreview({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. 요청하신 논리 구조에 맞춰 샘플 데이터를 재생성합니다.
    final List<_InboundItem> sampleItems = [
      // 첫 번째 PltNo (2단계 작업)
      _InboundItem(
        id: 1,
        pltNo: 'PU_A_111111',
        source: 'A01-01-01',
        destination: 'T01-TEMP-01',
      ),
      _InboundItem(
        id: 2,
        pltNo: 'PU_A_111111',
        source: 'T01-TEMP-01',
        destination: 'C05-01-02',
      ),
      // 두 번째 PltNo (2단계 작업)
      _InboundItem(
        id: 3,
        pltNo: 'PU_B_222222',
        source: 'B02-03-01',
        destination: 'T02-TEMP-01',
      ),
      _InboundItem(
        id: 4,
        pltNo: 'PU_B_222222',
        source: 'T02-TEMP-01',
        destination: 'D11-03-05',
      ),
      // 세 번째 PltNo (2단계 작업)
      _InboundItem(
        id: 5,
        pltNo: 'PU_C_333333',
        source: 'F01-04-08',
        destination: 'T03-TEMP-01',
      ),
      _InboundItem(
        id: 6,
        pltNo: 'PU_C_333333',
        source: 'T03-TEMP-01',
        destination: 'H09-01-03',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// 상단 버튼 바
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('삭제'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
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
                    onPressed: () {},
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

            /// 중앙 오더 상세 표시
            FormCardLayout(
              contentPadding: 12,
              verticalMargin: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildInfoField('No.', 'PU_A_111111'),
                        _buildInfoField('제품', '1단'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        _buildInfoField('시간', '2025-09-09, 16:00:27'),
                        _buildInfoField('담당', '최제인'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            /// 하단 데이터그리드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  // 세로 스크롤은 유지
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
                    rows: sampleItems.map((item) {
                      return DataRow(
                        cells: [
                          DataCell(Text(item.id.toString())),
                          DataCell(Text(item.pltNo)),
                          DataCell(Text(item.source)),
                          DataCell(Text(item.destination)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 정보 필드 UI 헬퍼 메서드 (변경 없음)
  Widget _buildInfoField(String fieldName, [String? fieldValue]) {
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
