class PendingOrderEntity {
  final int? missionType;
  final String? huId;
  final int? targetRackLevel;
  final String? sourceBin;
  final String? destinationBin;
  final bool? isWrapped;
  final int? destinationArea;
  final String? doNo;

  PendingOrderEntity({
    this.missionType,
    this.huId,
    this.targetRackLevel,
    this.sourceBin,
    this.destinationBin,
    this.isWrapped,
    this.destinationArea,
    this.doNo,
  });
}
