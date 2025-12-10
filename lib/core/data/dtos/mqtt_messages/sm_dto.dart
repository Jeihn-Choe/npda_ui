class SmDto {
  final int missionNo;
  final int subMissionNo;
  final int missionType;
  final String huId; // ✨ 변경: non-nullable
  final String? doNo;
  final String startTime; // ✨ 변경: non-nullable
  final int? targetRackLevel;
  final String sourceBin; // ✨ 변경: non-nullable
  final String destinationBin; // ✨ 변경: non-nullable
  final bool isWrapped; // ✨ 변경: non-nullable
  final int? subMissionStatus;
  final String? robotName;

  SmDto({
    required this.missionNo,
    required this.subMissionNo,
    required this.missionType,
    required this.huId,
    this.doNo,
    required this.startTime,
    this.targetRackLevel, // ✨ 변경: required 제거
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    this.subMissionStatus, // ✨ 변경: required 제거
    this.robotName,
  });

  factory SmDto.fromJson(Map<String, dynamic> json) {
    return SmDto(
      missionNo: json['missionNo'] as int,
      subMissionNo: json['subMissionNo'] as int,
      missionType: json['missionType'] as int,
      huId: json['huId'] as String? ?? '',
      doNo: json['doNo'] as String?,
      startTime: json['startTime'] as String? ?? '',
      targetRackLevel: json['targetRackLevel'] as int?,
      sourceBin: json['sourceBin'] as String? ?? '',
      destinationBin: json['destinationBin'] as String? ?? '',
      isWrapped: json['isWrapped'] as bool? ?? false,
      subMissionStatus: json['subMissionStatus'] as int?,
      robotName: json['robotName'] as String?,
    );
  }

  factory SmDto.toJson(Map<String, dynamic> json) {
    return SmDto(
      missionNo: json['missionNo'] as int,
      subMissionNo: json['subMissionNo'] as int,
      missionType: json['missionType'] as int,
      huId: json['huId'] as String? ?? '', // ✨ 수정: 기본값 제공
      doNo: json['doNo'] as String?,
      startTime: json['startTime'] as String? ?? '', // ✨ 수정: 기본값 제공
      targetRackLevel: json['targetRackLevel'] as int?,
      sourceBin: json['sourceBin'] as String? ?? '', // ✨ 수정: 기본값 제공
      destinationBin: json['destinationBin'] as String? ?? '', // ✨ 수정: 기본값 제공
      isWrapped: json['isWrapped'] as bool? ?? false, // ✨ 수정: 기본값 제공
      subMissionStatus: json['subMissionStatus'] as int?,
      robotName: json['robotName'] as String?,
    );
  }

  factory SmDto.toEntity(Map<String, dynamic> json) {
    return SmDto(
      missionNo: json['missionNo'] as int,
      subMissionNo: json['subMissionNo'] as int,
      missionType: json['missionType'] as int,
      huId: json['huId'] as String? ?? '', // ✨ 수정: 기본값 제공
      doNo: json['doNo'] as String?,
      startTime: json['startTime'] as String? ?? '', // ✨ 수정: 기본값 제공
      targetRackLevel: json['targetRackLevel'] as int?,
      sourceBin: json['sourceBin'] as String? ?? '', // ✨ 수정: 기본값 제공
      destinationBin: json['destinationBin'] as String? ?? '', // ✨ 수정: 기본값 제공
      isWrapped: json['isWrapped'] as bool? ?? false, // ✨ 수정: 기본값 제공
      subMissionStatus: json['subMissionStatus'] as int?,
      robotName: json['robotName'] as String?,
    );
  }
}
