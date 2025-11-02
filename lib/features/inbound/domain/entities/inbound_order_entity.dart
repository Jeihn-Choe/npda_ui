class InboundOrderEntity {
  final String pltNo;
  final DateTime workStartTime;
  final String selectedRackLevel;
  final String userId;
  final bool isWrapped;

  const InboundOrderEntity({
    required this.pltNo,
    required this.workStartTime,
    required this.selectedRackLevel,
    required this.userId,
    required this.isWrapped,
  });

  InboundOrderEntity copyWith({
    String? pltNo,
    DateTime? workStartTime,
    String? selectedRackLevel,
    String? userId,
    bool? isWrapped,
  }) {
    return InboundOrderEntity(
      pltNo: pltNo ?? this.pltNo,
      workStartTime: workStartTime ?? this.workStartTime,
      selectedRackLevel: selectedRackLevel ?? this.selectedRackLevel,
      userId: userId ?? this.userId,
      isWrapped: isWrapped ?? false,
    );
  }

  @override
  String toString() {
    return 'InboundOrderEntity(pltNo: $pltNo, workStartTime: $workStartTime, selectedRackLevel: $selectedRackLevel, userId: $userId)';
  }
}