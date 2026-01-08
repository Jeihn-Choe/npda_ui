class OrderValidationReqDto {
  final String huId;
  final String binId;
  final String employeeId;

  OrderValidationReqDto({
    required this.huId,
    required this.binId,
    required this.employeeId,
  });

  Map<String, dynamic> toJson() {
    return {
      'huId': huId,
      'binId': binId,
      'employeeId': employeeId,
    };
  }
}
