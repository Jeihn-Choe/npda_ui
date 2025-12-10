class InboundSmEntity {
  final int missionNo;
  final int subMissionNo;
  final int missionType;
  final String pltNo; // huId에서 매핑
  final String startTime;
  final int targetRackLevel;
  final String sourceBin;
  final String destinationBin;
  final bool isWrapped;
  final int subMissionStatus;
  final String robotName;

  InboundSmEntity({
    required this.missionNo,
    required this.subMissionNo,
    required this.missionType,
    required this.pltNo,
    required this.startTime,
    required this.targetRackLevel,
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    required this.subMissionStatus,
    required this.robotName,
  });
}
