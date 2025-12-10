/// 미션 정보 DTO
class PoDto {
  /// 미션 종류 (0: 입고, 1: 출고, 2: 1층 출고)
  final int missionType;

  /// 팔레트 PU/HU 번호 (출고, 1층출고 시 null)
  final String? huId;

  /// 목표 랙 층수 (0: 랜덤, 1: 1단, 2: 2단, 3: 3단)
  final int targetRackLevel;

  /// 출발지 BIN Number
  final String sourceBin;

  /// 목적지 BIN Number
  final String destinationBin;

  /// 래핑 여부
  final bool isWrapped;

  /// 최종 목적지 (입고 시 목적 구역 설정: 0: 3층 지정구역, 1: 3층 랙)
  final int destinationArea;

  /// DO 번호
  final String? doNo;

  PoDto({
    required this.missionType,
    this.huId,
    required this.targetRackLevel,
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    required this.destinationArea,
    this.doNo,
  });

  /// JSON to DTO
  factory PoDto.fromJson(Map<String, dynamic> json) {
    return PoDto(
      // Enum 변환 없이 정수 그대로 할당
      missionType: json['missionType'] as int,
      huId: json['huId'] as String?,
      targetRackLevel: json['targetRackLevel'] as int,
      sourceBin: json['sourceBin'] as String,
      destinationBin: json['destinationBin'] as String,
      isWrapped: json['isWrapped'] as bool,
      destinationArea: json['destinationArea'] as int,
      doNo: json['doNo'] as String?,
    );
  }

  /// DTO to JSON
  Map<String, dynamic> toJson() {
    return {
      'missionType': missionType,
      'huId': huId,
      'targetRackLevel': targetRackLevel,
      'sourceBin': sourceBin,
      'destinationBin': destinationBin,
      'isWrapped': isWrapped,
      'destinationArea': destinationArea,
      'doNo': doNo,
    };
  }

  /// copyWith
  PoDto copyWith({
    int? missionType,
    String? huId,
    int? targetRackLevel,
    String? sourceBin,
    String? destinationBin,
    bool? isWrapped,
    int? destinationArea,
    String? doNo,
  }) {
    return PoDto(
      missionType: missionType ?? this.missionType,
      huId: huId ?? this.huId,
      targetRackLevel: targetRackLevel ?? this.targetRackLevel,
      sourceBin: sourceBin ?? this.sourceBin,
      destinationBin: destinationBin ?? this.destinationBin,
      isWrapped: isWrapped ?? this.isWrapped,
      destinationArea: destinationArea ?? this.destinationArea,
      doNo: doNo ?? this.doNo,
    );
  }
}
