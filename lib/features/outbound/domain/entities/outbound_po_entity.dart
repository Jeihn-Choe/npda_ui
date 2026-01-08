class OutboundPoEntity {
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

  /// 고유 식별자 (String)
  final String uid;

  /// Outbound는 SM 도 취급 subMissionNo랑 현재 작업중인지 여부 파악해야함.
  final int? subMissionNo;
  final int? subMissionStatus;

  OutboundPoEntity({
    required this.missionType,
    this.huId,
    required this.targetRackLevel,
    required this.sourceBin,
    required this.destinationBin,
    required this.isWrapped,
    required this.destinationArea,
    required this.doNo,
    required this.uid,
    this.subMissionNo,
    this.subMissionStatus,
  });

  OutboundPoEntity copyWith({
    int? missionType,
    String? huId,
    int? targetRackLevel,
    String? sourceBin,
    String? destinationBin,
    bool? isWrapped,
    int? destinationArea,
    String? doNo,
    String? uid,
    int? subMissionNo,
    int? subMissionStatus,
  }) {
    return OutboundPoEntity(
      missionType: missionType ?? this.missionType,
      huId: huId ?? this.huId,
      targetRackLevel: targetRackLevel ?? this.targetRackLevel,
      sourceBin: sourceBin ?? this.sourceBin,
      destinationBin: destinationBin ?? this.destinationBin,
      isWrapped: isWrapped ?? this.isWrapped,
      destinationArea: destinationArea ?? this.destinationArea,
      doNo: doNo ?? this.doNo,
      uid: uid ?? this.uid,
      subMissionNo: subMissionNo ?? this.subMissionNo,
      subMissionStatus: subMissionStatus ?? this.subMissionStatus,
    );
  }
}
