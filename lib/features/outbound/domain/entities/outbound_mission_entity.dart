import '../../../../core/domain/entities/sm_entity.dart';

class OutboundMissionEntity {
  final int missionNo;
  final int subMissionNo;
  final String pltNo;
  final String sourceBin;
  final String destinationBin;
  final int? subMissionStatus;
  final String? startTime;
  final int missionType; // outbound 미션 필터링에 사용될 수 있음
  final bool isWrapped;

  const OutboundMissionEntity({
    required this.missionNo,
    required this.subMissionNo,
    required this.pltNo,
    required this.sourceBin,
    required this.destinationBin,
    required this.subMissionStatus,
    this.startTime,
    required this.missionType,
    required this.isWrapped,
  });

  // SmEntity로부터 OutboundMissionEntity를 생성하는 팩토리 생성자
  factory OutboundMissionEntity.fromSmEntity(SmEntity smEntity) {
    return OutboundMissionEntity(
      missionNo: smEntity.missionNo,
      subMissionNo: smEntity.subMissionNo,
      pltNo: smEntity.pltNo,
      sourceBin: smEntity.sourceBin,
      destinationBin: smEntity.destinationBin,
      subMissionStatus: smEntity.subMissionStatus,
      startTime: smEntity.startTime,
      missionType: smEntity.missionType,
      isWrapped: smEntity.isWrapped,
    );
  }
}
