class InboundWorkItem {
  final String missionType;
  final String missionNo;
  final String subMissionNo;
  final String pltNo;
  final String sourceBin;
  final String destinationBin;
  final DateTime createdAt;

  InboundWorkItem({
    required this.missionType,
    required this.missionNo,
    required this.subMissionNo,
    required this.pltNo,
    required this.sourceBin,
    required this.destinationBin,
    required this.createdAt,
  });

  factory InboundWorkItem.fromJson(Map<String, dynamic> json) {
    return InboundWorkItem(
      missionType: json['missionType'] as String,
      missionNo: json['missionNo'] as String,
      subMissionNo: json['subMissionNo'] as String,
      pltNo: json['pltNo'] as String,
      sourceBin: json['sourceBin'] as String,
      destinationBin: json['destinationBin'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
