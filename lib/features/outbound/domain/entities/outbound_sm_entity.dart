class OutboundSmEntity {
  final int missionNo;
  final int subMissionNo;
  final String pltNo;
  final String doNo;
  final String sourceBin;
  final String destinationBin;
  final int? subMissionStatus;
  final String? startTime;
  final int missionType;
  final bool isWrapped;
  final String? robotName;

  const OutboundSmEntity({
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
