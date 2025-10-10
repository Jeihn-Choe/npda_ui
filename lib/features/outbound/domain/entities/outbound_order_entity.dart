import 'package:equatable/equatable.dart';

class OutboundOrderEntity extends Equatable {
  final String orderNo;
  final String? doNo;
  final String? savedBinNo;
  final DateTime startTime;
  final String userId;

  const OutboundOrderEntity({
    required this.orderNo,
    this.doNo,
    this.savedBinNo,
    required this.startTime,
    required this.userId,
  });

  @override
  List<Object?> get props => [orderNo, doNo, savedBinNo, startTime, userId];
}
