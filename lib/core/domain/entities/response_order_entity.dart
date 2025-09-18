class ResponseOrderEntity {
  final String? cmdId;
  final bool isSuccess;
  final String? message;

  const ResponseOrderEntity({
    required this.cmdId,
    required this.isSuccess,
    required this.message,
  });

  factory ResponseOrderEntity.success({String? cmdId}) {
    return ResponseOrderEntity(
      cmdId: cmdId ?? '',
      isSuccess: true,
      message: 'Success',
    );
  }

  factory ResponseOrderEntity.failure({String? cmdId, String? message}) {
    return ResponseOrderEntity(
      cmdId: cmdId ?? '',
      isSuccess: false,
      message: message ?? 'Failure',
    );
  }
}
