class SmEntity {
  final int missionNo;
  final int subMissionNo;
  final int missionType;
  final String pltNo;
  final String? doNo;
  final String startTime;
  final int targetRackLevel;
  final String sourceBin;
  final String destinationBin;
  final bool isWrapped;
  final int? subMissionStatus;

  SmEntity({
    required this.missionNo,
    required this.subMissionNo,
    required this.missionType,
    required this.pltNo,
    required this.doNo,
    required this.startTime,
    required this.targetRackLevel,
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    required this.subMissionStatus,
  });

  factory SmEntity.fromJson(Map<String, dynamic> json) {
    return SmEntity(
      missionNo: json['missionNo'] as int,
      subMissionNo: json['subMissionNo'] as int,
      missionType: json['missionType'] as int,
      pltNo: json['pltNo'] as String,
      doNo: json['doNo'] as String?,
      startTime: json['startTime'] as String,
      targetRackLevel: json['targetRackLevel'] as int,
      sourceBin: json['sourceBin'] as String,
      destinationBin: json['destinationBin'] as String,
      isWrapped: json['isWrapped'] as bool,
      subMissionStatus: json['subMissionStatus'] as int,
    );
  }
}
