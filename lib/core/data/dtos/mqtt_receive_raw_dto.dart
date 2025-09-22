

class MqttReceiveRawDto {
  final String cmdId;
  final Map<String, dynamic> payload;

  MqttReceiveRawDto({required this.cmdId, required this.payload});

  factory MqttReceiveRawDto.fromJson(Map<String, dynamic> json) {
    return MqttReceiveRawDto(
      cmdId: json['cmdId'] as String,
      payload: json['payload'] as Map<String, dynamic>,
    );
  }
}

class SubMissionDto {
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

  SubMissionDto({
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

  factory SubMissionDto.fromJson(Map<String, dynamic> json) {
    return SubMissionDto(
      missionNo: json['missionNo'] as int,
      subMissionNo: json['subMissionNo'] as int,
      missionType: json['missionType'] as int,
      pltNo: json['pltNo'] as String,
      startTime: json['startTime'] as String,
      targetRackLevel: json['targetRackLevel'] as int,
      sourceBin: json['sourceBin'] as String,
      destinationBin: json['destinationBin'] as String,
      isWrapped: json['isWrapped'] as bool,
      subMissionStatus: json['subMissionStatus'] as int,
    );
  }
}

class BinDto {
  final String binId;
  final String area;
  final int priority;

  BinDto({required this.binId, required this.area, required this.priority});

  factory BinDto.fromJson(Map<String, dynamic> json) {
    return BinDto(
      binId: json['binId'] as String,
      area: json['area'] as String,
      priority: json['priority'] as int,
    );
  }
}
