class ResponseOrderEntity {
  final String? cmdId;
  final bool isSuccess;
  final String? msg;

  const ResponseOrderEntity({
    required this.cmdId,
    required this.isSuccess,
    required this.msg,
  });

  factory ResponseOrderEntity.success({String? cmdId, String? msg}) {
    return ResponseOrderEntity(cmdId: cmdId, isSuccess: true, msg: msg);
  }

  factory ResponseOrderEntity.failure({String? cmdId, String? msg}) {
    return ResponseOrderEntity(
      cmdId: cmdId,
      isSuccess: false,
      msg: msg ?? 'Failure',
    );
  }
}
