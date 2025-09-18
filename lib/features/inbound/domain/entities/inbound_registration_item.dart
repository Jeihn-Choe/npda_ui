class InboundRegistrationItem {
  final String pltNo;
  final DateTime workStartTime;
  final String selectedRackLevel;
  final String userId;
  final bool isWrapped;

  const InboundRegistrationItem({
    required this.pltNo,
    required this.workStartTime,
    required this.selectedRackLevel,
    required this.userId,
    required this.isWrapped,
  });

  InboundRegistrationItem copyWith({
    String? pltNo,
    DateTime? workStartTime,
    String? selectedRackLevel,
    String? userId,
    bool? isWrapped,
  }) {
    return InboundRegistrationItem(
      pltNo: pltNo ?? this.pltNo,
      workStartTime: workStartTime ?? this.workStartTime,
      selectedRackLevel: selectedRackLevel ?? this.selectedRackLevel,
      userId: userId ?? this.userId,
      isWrapped: isWrapped ?? false,
    );
  }

  @override
  String toString() {
    return 'InboundRegistrationItem(pltNo: $pltNo, workStartTime: $workStartTime, selectedRackLevel: $selectedRackLevel, userId: $userId)';
  }
}
