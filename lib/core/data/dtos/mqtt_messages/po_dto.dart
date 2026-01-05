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

  /// 고유 식별자
  final String uid;

  /// 팔레트 수량 (1층 출고)
  final int? pltQty;

  /// 예약 시간 (1층 출고)
  final String? reservationTime;

  PoDto({
    required this.missionType,
    this.huId,
    required this.targetRackLevel,
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    required this.destinationArea,
    this.doNo,
    required this.uid,
    this.pltQty,
    this.reservationTime,
  });

  /// JSON to DTO
  factory PoDto.fromJson(Map<String, dynamic> json) {
    return PoDto(
      missionType: json['missionType'] as int? ?? 0,
      huId: json['huId'] as String?,
      targetRackLevel: json['targetRackLevel'] as int? ?? 0,
      sourceBin: json['sourceBin'] as String? ?? '',
      destinationBin: json['destinationBin'] as String? ?? '',
      isWrapped: json['isWrapped'] as bool? ?? false,
      destinationArea: json['destinationArea'] as int? ?? 0,
      doNo: json['doNo'] as String?,
      uid: json['uid'] as String? ?? '',
      pltQty: json['pltQty'] as int?,
      reservationTime: json['reservationTime'] as String?,
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
      'uid': uid,
      'pltQty': pltQty,
      'reservationTime': reservationTime,
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
    String? uid,
    int? pltQty,
    String? reservationTime,
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
      uid: uid ?? this.uid,
      pltQty: pltQty ?? this.pltQty,
      reservationTime: reservationTime ?? this.reservationTime,
    );
  }
}
