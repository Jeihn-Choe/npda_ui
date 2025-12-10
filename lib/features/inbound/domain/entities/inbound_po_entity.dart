class InboundPoEntity {
  /// 미션 종류 (0: 입고, 1: 출고, 2: 1층 출고)
  final int missionType;

  /// 팔레트 PU/HU 번호 (String, 출고 관련 시 null 가능)
  final String? huId;

  /// 목표 랙 층수 (0: 랜덤, 1: 1단, 2: 2단, 3: 3단)
  final int targetRackLevel;

  /// 출발지 (BIN Number)
  final String sourceBin;

  /// 목적지 (BIN Number)
  final String destinationBin;

  /// 래핑 여부 (Bool)
  final bool isWrapped;

  /// 최종 목적지 (0: 3층 지정구역, 1: 3층 랙)
  final int destinationArea;

  /// DO 번호 (String)
  final String doNo;

  InboundPoEntity({
    required this.missionType,
    this.huId,
    required this.targetRackLevel,
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    required this.destinationArea,
    required this.doNo,
  });
}
