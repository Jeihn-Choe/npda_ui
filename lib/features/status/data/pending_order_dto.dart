/// 메인 응답 객체 (Command ID + Payload)
class PendingOrderResponse {
  final String cmdId;
  final List<MissionItem> payload;

  PendingOrderResponse({required this.cmdId, required this.payload});

  // JSON 데이터를 객체로 변환 (Deserialize)
  factory PendingOrderResponse.fromJson(Map<String, dynamic> json) {
    return PendingOrderResponse(
      cmdId: json['cmdId'] as String,
      payload:
          (json['payload'] as List<dynamic>?)
              ?.map((e) => MissionItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // 객체를 JSON 데이터로 변환 (Serialize)
  Map<String, dynamic> toJson() {
    return {'cmdId': cmdId, 'payload': payload.map((e) => e.toJson()).toList()};
  }
}

/// 페이로드 내부의 미션 아이템
class MissionItem {
  /// 미션 종류 (0: 입고, 1: 출고, 2: 1층 출고)
  final int missionType;

  /// 팔레트 PU/HU 번호 (출고 시 null 가능)
  final String? huId;

  /// 목표 랙 층수 (0: 랜덤, 1: 1단, 2: 2단, 3: 3단)
  final int targetRackLevel;

  /// 출발지 (BIN Number)
  final String sourceBin;

  /// 목적지 (BIN Number)
  final String destinationBin;

  /// 래핑 여부
  final bool isWrapped;

  /// 최종 목적지 (0: 3층 지정구역, 1: 3층 랙)
  final int destinationArea;

  /// DO 번호
  final String doNo;

  MissionItem({
    required this.missionType,
    this.huId,
    required this.targetRackLevel,
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    required this.destinationArea,
    required this.doNo,
  });

  factory MissionItem.fromJson(Map<String, dynamic> json) {
    return MissionItem(
      missionType: json['missionType'] as int,
      huId: json['huId'] as String?,
      // Nullable 처리
      targetRackLevel: json['targetRackLevel'] as int,
      sourceBin: json['sourceBin'] as String,
      destinationBin: json['destinationBin'] as String,
      isWrapped: json['isWrapped'] is int
          ? (json['isWrapped'] == 1) // 만약 서버에서 0/1로 준다면
          : json['isWrapped'] as bool,
      // true/false로 준다면
      destinationArea: json['destinationArea'] as int,
      doNo: json['doNo'] as String,
    );
  }

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
}
