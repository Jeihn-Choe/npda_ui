class RequestOrderDto {
  final String cmdId;
  final List<WorkItem> missionList;

  RequestOrderDto({required this.cmdId, required this.missionList});

  factory RequestOrderDto.fromJson(Map<String, dynamic> json) {
    var list = json['payload'] as List;

    // Map(i) 로부터 WorkItem 객체 생성해야 하므로 fromJson 사용
    List<WorkItem> missionList = list.map((i) => WorkItem.fromJson(i)).toList();

    return RequestOrderDto(
      cmdId: json['cmdId'] as String,
      missionList: missionList,
    );
  }

  // 객체를 Map(Json)으로 변환
  Map<String, dynamic> toJson() {
    return {
      'cmdId': cmdId,
      'payload': missionList.map((item) => item.toJson()).toList(),
    };
  }
}

class WorkItem {
  final int missionType;
  final String? pltNo;
  final DateTime? startTime;
  final int? targetRackLevel;
  final String employeeId;
  final String? sourceBin;
  final String? destinationBin;
  final bool? isWrapped;
  final int? destinationArea;

  WorkItem({
    required this.missionType,
    this.pltNo,
    this.startTime,
    this.targetRackLevel,
    required this.employeeId,
    this.sourceBin,
    this.destinationBin,
    this.isWrapped,
    this.destinationArea,
  });

  factory WorkItem.fromJson(Map<String, dynamic> json) {
    return WorkItem(
      missionType: json['missionType'] as int,
      pltNo: json['pltNo'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      targetRackLevel: json['targetRackLevel'] as int?,
      employeeId: json['employeeId'] as String,
      sourceBin: json['sourceBin'] as String?,
      destinationBin: json['destinationBin'] as String?,
      isWrapped: json['isWrapped'] as bool?,
      destinationArea: json['destinationArea'] as int?,
    );
  }

  // 객체를 Map(Json)으로 변환
  Map<String, dynamic> toJson() {
    return {
      'missionType': missionType,
      'pltNo': pltNo,
      'startTime': startTime?.toIso8601String(),
      'targetRackLevel': targetRackLevel,
      'employeeId': employeeId,
      'sourceBin': sourceBin,
      'destinationBin': destinationBin,
      'isWrapped': isWrapped,
      'destinationArea': destinationArea,
    };
  }
}
