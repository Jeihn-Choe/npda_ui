class OutboundMissionEntity {
  final int missionNo;
  final int subMissionNo;
  final String pltNo;
  final String doNo;
  final String sourceBin;
  final String destinationBin;
  final int? subMissionStatus; // `int?` 유지
  final String? startTime; // `String?` 유지
  final int missionType;
  final bool isWrapped;
  final String? robotName; // `String?` 유지

  const OutboundMissionEntity({
    required this.missionNo,
    required this.subMissionNo,
    required this.pltNo,
    required this.doNo,
    required this.sourceBin,
    required this.destinationBin,
    required this.subMissionStatus,
    this.startTime,
    required this.missionType,
    required this.isWrapped,
    this.robotName,
  });
}
