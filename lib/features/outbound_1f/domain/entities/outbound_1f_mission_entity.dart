class Outbound1FMissionEntity {
  final int missionNo;
  final int subMissionNo;
  final String pltNo;
  final String sourceBin;
  final String destinationBin;
  final int? subMissionStatus;
  final String? startTime;
  final int missionType; // outbound 미션 필터링에 사용될 수 있음
  final bool isWrapped;
  final String? robotName;

  const Outbound1FMissionEntity({
    required this.missionNo,
    required this.subMissionNo,
    required this.pltNo,
    required this.sourceBin,
    required this.destinationBin,
    required this.subMissionStatus,
    this.startTime,
    required this.missionType,
    required this.isWrapped,
    this.robotName,
  });
}
