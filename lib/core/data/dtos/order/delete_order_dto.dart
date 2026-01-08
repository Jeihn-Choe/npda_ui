class DeleteOrdersDto {
  final String cmdId;
  final DeleteOrdersPayloadDto payload;

  DeleteOrdersDto({this.cmdId = "DO", required this.payload});

  Map<String, dynamic> toJson() {
    return {'cmdId': cmdId, 'payload': payload.toJson()};
  }
}

class DeleteOrdersPayloadDto {
  final List<String> uids;

  final List<int> subMissionNos;

  DeleteOrdersPayloadDto({required this.uids, required this.subMissionNos});

  Map<String, dynamic> toJson() {
    return {'uids': uids, 'subMissionNos': subMissionNos};
  }
}
