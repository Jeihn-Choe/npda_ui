class DeleteMissionsDto {
  final String cmdId;
  final List<String> payload;

  DeleteMissionsDto({this.cmdId = "DM", required this.payload});

  Map<String, dynamic> toJson() {
    return {'cmdId': cmdId, 'payload': payload};
  }
}
