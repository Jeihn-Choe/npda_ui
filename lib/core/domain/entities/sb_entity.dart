class SbEntity {
  final String binId;
  final String area;
  final int priority;

  SbEntity({required this.binId, required this.area, required this.priority});

  factory SbEntity.fromJson(Map<String, dynamic> json) {
    return SbEntity(
      binId: json['binId'] as String,
      area: json['area'] as String,
      priority: json['priority'] as int,
    );
  }
}
