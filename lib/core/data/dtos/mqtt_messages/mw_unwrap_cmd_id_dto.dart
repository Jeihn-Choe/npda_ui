class MwUnwrapCmdIdDto {
  final String cmdId;
  final dynamic payload;

  MwUnwrapCmdIdDto({required this.cmdId, required this.payload});

  factory MwUnwrapCmdIdDto.fromJson(Map<String, dynamic> json) {
    return MwUnwrapCmdIdDto(
      cmdId: json['cmdId'] as String,
      payload: json['payload'],
    );
  }
}
