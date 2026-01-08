import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_po_entity.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_po_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_po_entity.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_po_list_provider.dart';
import 'package:npda_ui_flutter/features/outbound_1f/domain/entities/outbound_1f_po_entity.dart';
import 'package:npda_ui_flutter/features/outbound_1f/presentation/providers/outbound_1f_po_list_provider.dart';
import 'package:npda_ui_flutter/features/status/presentation/status_page_vm.dart';

import '../../../core/constants/colors.dart';

class StatusPage extends ConsumerStatefulWidget {
  const StatusPage({super.key});

  @override
  ConsumerState<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends ConsumerState<StatusPage> {
  @override
  void initState() {
    super.initState();
    // 🚀 페이지가 열릴 때 초기화 (닫을 때 dispose에서 하면 에러 발생 가능성 있음)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inboundPoListProvider.notifier).disableSelectionMode();
      ref.read(outboundPoListProvider.notifier).disableSelectionMode();
      ref.read(outbound1fPoListProvider.notifier).disableSelectionMode();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusState = ref.watch(statusPageVmProvider);
    final inboundPoListState = statusState.inboundPoListState;
    final outboundPoListState = statusState.outboundPoListState;
    final outbound1FPoListState = statusState.outbound1FPoListState;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.90,
      backgroundColor: AppColors.grey100,
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
                  _buildDeviceStatusRow(context, ref, statusState),

                  // --- [섹션 2] Order Status ---
                  const SizedBox(height: 20),

                  // 1) 입고 테이블
                  _buildExpandableSection(
                    context,
                    title: '입고 (Inbound)',
                    color: AppColors.celltrionGreen,
                    trailing:
                        inboundPoListState.isSelectionModeActive
                            ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () {
                                ref
                                    .read(inboundPoListProvider.notifier)
                                    .deleteSelectedPos();
                              },
                            )
                            : null,
                    content: _buildStyledTable<InboundPoEntity>(
                      columns: ['HuId', '출발지', '', ''],
                      columnWidths: {
                        0: const FlexColumnWidth(1.4),
                        1: const FlexColumnWidth(1.8),
                        2: const FlexColumnWidth(0.8),
                        3: const FlexColumnWidth(0.6),
                      },
                      items: inboundPoListState.poList,
                      isSelectionMode: inboundPoListState.isSelectionModeActive,
                      selectedKeys: inboundPoListState.selectedPoKeys,
                      keyExtractor: (item) => item.uid,
                      onRowTap:
                          (item) => ref
                              .read(inboundPoListProvider.notifier)
                              .togglePoForDeletion(item),
                      onRowLongPress:
                          (item) => ref
                              .read(inboundPoListProvider.notifier)
                              .enableSelectionMode(item.uid),
                      rowBuilder: (po) {
                        return [
                          po.huId ?? '-',
                          po.sourceBin,
                          po.destinationArea == 0 ? '지정구역' : '랙',
                          '${po.targetRackLevel}단',
                        ];
                      },
                    ),
                  ),

                  // 2) 출고 테이블
                  _buildExpandableSection(
                    context,
                    title: '출고 (Outbound)',
                    color: AppColors.orange,
                    trailing:
                        outboundPoListState.isSelectionModeActive
                            ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () {
                                ref
                                    .read(outboundPoListProvider.notifier)
                                    .deleteSelectedPos();
                              },
                            )
                            : null,
                    content: _buildStyledTable<OutboundPoEntity>(
                      columns: ['DO No', '저장빈 No'],
                      items: outboundPoListState.poList,
                      isSelectionMode:
                          outboundPoListState.isSelectionModeActive,
                      selectedKeys: outboundPoListState.selectedPoKeys,
                      keyExtractor:
                          (item) =>
                              item.uid.isNotEmpty
                                  ? item.uid
                                  : "SUB:${item.subMissionNo}",
                      onRowTap:
                          (item) => ref
                              .read(outboundPoListProvider.notifier)
                              .togglePoForDeletion(item),
                      onRowLongPress:
                          (item) {
                            final key =
                                item.uid.isNotEmpty
                                    ? item.uid
                                    : "SUB:${item.subMissionNo}";
                            ref
                                .read(outboundPoListProvider.notifier)
                                .enableSelectionMode(key);
                          },
                      rowBuilder: (po) {
                        return [
                          po.doNo.isNotEmpty ? po.doNo : '',
                          po.sourceBin.isNotEmpty ? po.sourceBin : '',
                        ];
                      },
                    ),
                  ),

                  // 3) 1층 출고 테이블
                  _buildExpandableSection(
                    context,
                    title: '1층 출고 (1F Outbound)',
                    color: AppColors.purple,
                    trailing:
                        outbound1FPoListState.isSelectionModeActive
                            ? IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                              onPressed: () {
                                ref
                                    .read(outbound1fPoListProvider.notifier)
                                    .deleteSelectedPos();
                              },
                            )
                            : null,
                    content: _buildStyledTable<Outbound1fPoEntity>(
                      columns: ['출발구역', '목적구역', '수량', '예약시간'],
                      columnWidths: {
                        0: const FlexColumnWidth(1.2),
                        1: const FlexColumnWidth(1.2),
                        2: const FlexColumnWidth(0.6),
                        3: const FlexColumnWidth(1.5),
                      },
                      items: outbound1FPoListState.poList,
                      isSelectionMode:
                          outbound1FPoListState.isSelectionModeActive,
                      selectedKeys: outbound1FPoListState.selectedPoKeys,
                      keyExtractor: (item) => item.uid,
                      onRowTap:
                          (item) => ref
                              .read(outbound1fPoListProvider.notifier)
                              .togglePoForDeletion(item),
                      onRowLongPress:
                          (item) => ref
                              .read(outbound1fPoListProvider.notifier)
                              .enableSelectionMode(item.uid),
                      rowBuilder: (po) {
                        return [
                          po.sourceBin,
                          po.destinationBin,
                          po.pltQty?.toString() ?? '-',
                          po.reservationTime ?? '-',
                        ];
                      },
                    ),
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

  Widget _buildExpandableSection(
    BuildContext context,
    {
    required String title,
    required Color color,
    required Widget content,
    Widget? trailing,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSubHeader(title, color),
            if (trailing != null) trailing,
          ],
        ),
        children: [
          const SizedBox(height: 8),
          content,
          const SizedBox(height: 12),
        ],
      ),
    );
  }

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

  Widget _buildDeviceStatusRow(
    BuildContext context,
    WidgetRef ref,
    StatusState state,
  ) {
    final devices = [
      {'name': '메인 E/V', 'status': state.isMainLiftAvailable},
      {'name': '보조 E/V', 'status': state.isSubLiftAvailable},
    ];

    return Row(
      children: devices.map((device) {
        final name = device['name'] as String;
        final isNormal = device['status'] as bool;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _buildDeviceCard(context, ref, name, isNormal),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeviceCard(
    BuildContext context,
    WidgetRef ref,
    String name,
    bool isNormal,
  ) {
    final statusColor = isNormal ? AppColors.success : AppColors.error;
    final buttonText = isNormal ? "고장 신고" : "수리 완료";

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.celltrionBlack,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 28,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: statusColor,
                elevation: 0,
                side: BorderSide(color: statusColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () =>
                  _showChangeStatusDialog(context, ref, name, !isNormal),
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
    WidgetRef ref,
    String deviceName,
    bool toStatus,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            toStatus ? "수리 완료 처리" : "고장 신고",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "$deviceName 의 상태를\n'${toStatus ? "정상" : "고장"}'(으)로 변경하시겠습니까?"
            ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text(
                "취소",
                style: TextStyle(color: AppColors.grey600),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: toStatus ? AppColors.success : AppColors.error,
              ),
              onPressed: () {
                ref
                    .read(statusPageVmProvider.notifier)
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

  Widget _buildStyledTable<T> ({
    required List<String> columns,
    required List<T> items,
    required List<String> Function(T) rowBuilder,
    required bool isSelectionMode,
    required Set<String> selectedKeys,
    required String Function(T) keyExtractor,
    required Function(T) onRowTap,
    required Function(T) onRowLongPress,
    Map<int, TableColumnWidth>? columnWidths,
  }) {
    if (items.isEmpty) {
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

    final displayColumns = isSelectionMode ? [''] + columns : columns;
    final Map<int, TableColumnWidth> displayColumnWidths = {};

    if (isSelectionMode) {
      displayColumnWidths[0] = const FixedColumnWidth(40);
      columnWidths?.forEach((key, value) {
        displayColumnWidths[key + 1] = value;
      });
    } else {
      if (columnWidths != null) displayColumnWidths.addAll(columnWidths);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.grey300),
        ),
        child: Table(
          columnWidths: displayColumnWidths,
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: const TableBorder(
            horizontalInside: BorderSide(color: AppColors.grey200),
          ),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: AppColors.grey100),
              children:
                  displayColumns
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
            ...items.map((item) {
              final key = keyExtractor(item);
              final isSelected = selectedKeys.contains(key);
              final cellData = rowBuilder(item);

              return TableRow(
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? AppColors.celltrionGreen.withOpacity(0.1)
                          : null,
                ),
                children: [
                  if (isSelectionMode)
                    TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) => onRowTap(item),
                        activeColor: AppColors.celltrionGreen,
                      ),
                    ),
                  ...cellData.map(
                    (text) => TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onLongPress: () => onRowLongPress(item),
                        onTap: () {
                          if (isSelectionMode) onRowTap(item);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8,
                          ),
                          child: Text(
                            text,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.celltrionBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}