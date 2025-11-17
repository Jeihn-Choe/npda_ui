class InboundOrderEntity {
  final String pltNo;
  final String sourceBin;
  final DateTime workStartTime;
  final String selectedRackLevel;
  final String userId;
  final int destinationArea;
  final bool isWrapped;

  const InboundOrderEntity({
    required this.pltNo,
    required this.sourceBin,
    required this.workStartTime,
    required this.selectedRackLevel,
    required this.userId,
    required this.destinationArea,
    required this.isWrapped,
  });

  InboundOrderEntity copyWith({
    String? pltNo,
    String? sourceBin,
    DateTime? workStartTime,
    String? selectedRackLevel,
    String? userId,
    int? destinationArea,
    bool? isWrapped,
  }) {
    return InboundOrderEntity(
      pltNo: pltNo ?? this.pltNo,
      sourceBin: sourceBin ?? this.sourceBin,
      workStartTime: workStartTime ?? this.workStartTime,
      selectedRackLevel: selectedRackLevel ?? this.selectedRackLevel,
      userId: userId ?? this.userId,
      destinationArea: destinationArea ?? this.destinationArea,
      isWrapped: isWrapped ?? false,
    );
  }

  @override
  String toString() {
    return 'InboundOrderEntity(pltNo: $pltNo, sourceBin: $sourceBin, workStartTime: $workStartTime, selectedRackLevel: $selectedRackLevel, userId: $userId, destinationArea: $destinationArea, isWrapped: $isWrapped)';
  }
}
