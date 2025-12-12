class Outbound1fSmEntity {
  final int missionNo;
  final int subMissionNo;
  final String pltNo;
  final String sourceBin;
  final String destinationBin;
  final int? subMissionStatus;
  final String? startTime;
  final int missionType;
  final bool isWrapped;
  final String? robotName;

  const Outbound1fSmEntity({
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

  Outbound1fSmEntity copyWith({
    int? missionNo,
    int? subMissionNo,
    String? pltNo,
    String? sourceBin,
    String? destinationBin,
    int? subMissionStatus,
    String? startTime,
    int? missionType,
    bool? isWrapped,
    String? robotName,
  }) {
    return Outbound1fSmEntity(
      missionNo: missionNo ?? this.missionNo,
      subMissionNo: subMissionNo ?? this.subMissionNo,
      pltNo: pltNo ?? this.pltNo,
      sourceBin: sourceBin ?? this.sourceBin,
      destinationBin: destinationBin ?? this.destinationBin,
      subMissionStatus: subMissionStatus ?? this.subMissionStatus,
      startTime: startTime ?? this.startTime,
      missionType: missionType ?? this.missionType,
      isWrapped: isWrapped ?? this.isWrapped,
      robotName: robotName ?? this.robotName,
    );
  }
}
