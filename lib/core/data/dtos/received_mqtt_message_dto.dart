class ReceivedMqttMessageDto {
  final String cmdId;
  final dynamic payload;

  ReceivedMqttMessageDto({required this.cmdId, required this.payload});

  factory ReceivedMqttMessageDto.fromJson(Map<String, dynamic> json) {
    return ReceivedMqttMessageDto(
      cmdId: json['cmdId'] as String,
      payload: json['payload'],
    );
  }
}
