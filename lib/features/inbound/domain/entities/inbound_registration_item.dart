class InboundRegistrationItem {
  final String pltNo;
  final DateTime workStartTime;
  final String selectedRackLevel;
  final String userId;

  const InboundRegistrationItem({
    required this.pltNo,
    required this.workStartTime,
    required this.selectedRackLevel,
    required this.userId,
  });

  InboundRegistrationItem copyWith({
    String? pltNo,
    DateTime? workStartTime,
    String? selectedRackLevel,
    String? userId,
  }) {
    return InboundRegistrationItem(
      pltNo: pltNo ?? this.pltNo,
      workStartTime: workStartTime ?? this.workStartTime,
      selectedRackLevel: selectedRackLevel ?? this.selectedRackLevel,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() {
    return 'InboundRegistrationItem(pltNo: $pltNo, workStartTime: $workStartTime, selectedRackLevel: $selectedRackLevel, userId: $userId)';
  }
}
