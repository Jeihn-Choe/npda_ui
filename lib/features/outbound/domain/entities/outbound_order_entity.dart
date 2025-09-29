import 'package:equatable/equatable.dart';

class OutboundOrderEntity extends Equatable {
  final String? doNo;
  final String? savedBinNo;
  final DateTime startTime;
  final String userId;

  OutboundOrderEntity({
    this.doNo,
    this.savedBinNo,
    required this.startTime,
    required this.userId,
  });

  @override
  List<Object?> get props => [doNo, savedBinNo, startTime, userId];
}
