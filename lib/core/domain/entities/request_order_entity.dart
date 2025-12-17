class RequestOrderEntity {
  final int? missionType;
  final String? pltNo;
  final String? doNo;
  final DateTime? startTime;
  final int? targetRackLevel;
  final String? employeeId;
  final String? sourceBin;
  final String? destinationBin;
  final bool? isWrapped;
  final int? destinationArea;
  final int? pltQty;

  RequestOrderEntity({
    required this.missionType,
    this.pltNo,
    this.doNo,
    this.startTime,
    this.targetRackLevel,
    required this.employeeId,
    this.sourceBin,
    this.destinationBin,
    this.isWrapped,
    this.destinationArea,
    this.pltQty,
  });

  factory RequestOrderEntity.fromJson(Map<String, dynamic> json) {
    return RequestOrderEntity(
      missionType: json['missionType'] as int,
      pltNo: json['pltNo'] as String?,
      doNo: json['doNo'] as String?,
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      targetRackLevel: json['targetRackLevel'] as int?,
      employeeId: json['employeeId'] as String,
      sourceBin: json['sourceBin'] as String?,
      destinationBin: json['destinationBin'] as String?,
      isWrapped: json['isWrapped'] as bool?,
      destinationArea: json['destinationArea'] as int?,
      pltQty: json['pltQty'] as int?,
    );
  }

  // 객체를 Map(Json)으로 변환
  Map<String, dynamic> toJson() {
    return {
      'missionType': missionType,
      'huId': pltNo,
      'doNo': doNo,
      'startTime': startTime?.toIso8601String(),
      'targetRackLevel': targetRackLevel,
      'employeeId': employeeId,
      'sourceBin': sourceBin,
      'destinationBin': destinationBin,
      'isWrapped': isWrapped,
      'destinationArea': destinationArea,
      'pltQty': pltQty,
    };
  }
}
