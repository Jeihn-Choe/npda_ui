class InboundMissionEntity {
  final int missionNo;
  final int subMissionNo;
  final int missionType;
  final String pltNo;
  final String startTime;
  final int targetRackLevel;
  final String sourceBin;
  final String destinationBin;
  final bool isWrapped;
  final int subMissionStatus;

  InboundMissionEntity({
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
  });

  factory InboundMissionEntity.fromSmEntity(sm) {
    return InboundMissionEntity(
      missionNo: sm.missionNo,
      subMissionNo: sm.subMissionNo,
      missionType: sm.missionType,
      pltNo: sm.pltNo,
      startTime: sm.startTime,
      targetRackLevel: sm.targetRackLevel,
      sourceBin: sm.sourceBin,
      destinationBin: sm.destinationBin,
      isWrapped: sm.isWrapped,
      subMissionStatus: sm.subMissionStatus,
    );
  }
}
