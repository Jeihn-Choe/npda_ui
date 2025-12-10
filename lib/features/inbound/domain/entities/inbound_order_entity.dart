class InboundOrderEntity {
  final String huId;
  final String sourceBin;
  final DateTime workStartTime;
  final String selectedRackLevel;
  final String userId;
  final int destinationArea;
  final bool isWrapped;

  const InboundOrderEntity({
    required this.huId,
    required this.sourceBin,
    required this.workStartTime,
    required this.selectedRackLevel,
    required this.userId,
    required this.destinationArea,
    required this.isWrapped,
  });

  InboundOrderEntity copyWith({
    String? huId,
    String? sourceBin,
    DateTime? workStartTime,
    String? selectedRackLevel,
    String? userId,
    int? destinationArea,
    bool? isWrapped,
  }) {
    return InboundOrderEntity(
      huId: huId ?? this.huId,
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
    return 'InboundOrderEntity(pltNo: $huId, sourceBin: $sourceBin, workStartTime: $workStartTime, selectedRackLevel: $selectedRackLevel, userId: $userId, destinationArea: $destinationArea, isWrapped: $isWrapped)';
  }
}
