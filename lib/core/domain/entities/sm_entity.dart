class SmEntity {
  final int missionNo;
  final int subMissionNo;
  final int missionType;
  final String huId;
  final String? doNo;
  final String startTime;
  final int? targetRackLevel;
  final String sourceBin;
  final String destinationBin;
  final bool? isWrapped;
  final int? subMissionStatus;
  final String? robotName;

  SmEntity({
    required this.missionNo,
    required this.subMissionNo,
    required this.missionType,
    required this.huId,
    this.doNo,
    required this.startTime,
    required this.targetRackLevel,
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    required this.subMissionStatus,
    this.robotName,
  });

  factory SmEntity.fromJson(Map<String, dynamic> json) {
    return SmEntity(
      missionNo: json['missionNo'] as int,
      subMissionNo: json['subMissionNo'] as int,
      missionType: json['missionType'] as int,
      huId: json['huid'] as String? ?? '',
      doNo: json['doNo'] as String? ?? '',
      startTime: json['startTime'] as String? ?? '',
      targetRackLevel: json['targetRackLevel'] as int?,
      sourceBin: json['sourceBin'] as String? ?? '',
      destinationBin: json['destinationBin'] as String? ?? '',
      isWrapped: json['isWrapped'] as bool? ?? false,
      subMissionStatus: json['subMissionStatus'] as int?,
      robotName: json['robotName'] as String?,
    );
  }
}
