import 'package:equatable/equatable.dart';

class Outbound1FOrderEntity extends Equatable {
  final String orderNo;
  final int missionType;
  final String? sourceBin;
  final String? destinationBin;
  final DateTime startTime;
  final int pltQty;
  final String userId;

  const Outbound1FOrderEntity({
    required this.orderNo,
    this.missionType = 2,
    this.sourceBin,
    this.destinationBin,
    required this.startTime,
    required this.pltQty,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    orderNo,
    missionType,
    sourceBin,
    destinationBin,
    startTime,
    pltQty,
    userId,
  ];
}
