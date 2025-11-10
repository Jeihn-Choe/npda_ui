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
  final String robotName;

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
    required this.robotName,
  });

  factory InboundMissionEntity.fromSmEntity(sm) {
    return InboundMissionEntity(
      missionNo: sm.missionNo,
      subMissionNo: sm.subMissionNo,
      missionType: sm.missionType,
      pltNo: sm.huId,
      // SmEntity는 pltNo 대신 huId를 사용
      startTime: sm.startTime,
      targetRackLevel: sm.targetRackLevel,
      sourceBin: sm.sourceBin,
      destinationBin: sm.destinationBin,
      isWrapped: sm.isWrapped,
      subMissionStatus: sm.subMissionStatus ?? 0,
      // null일 수 있으므로 기본값 설정
      robotName: sm.robotName ?? '', // null일 수 있으므로 기본값 설정
    );
  }
}
