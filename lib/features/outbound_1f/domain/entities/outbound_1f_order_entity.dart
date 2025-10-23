import 'package:equatable/equatable.dart';

class Outbound1FOrderEntity extends Equatable {
  final String orderNo; // 🚀 추가된 부분
  final int missionType;
  final String? pickingArea;
  final String? unloadArea;
  final DateTime startTime;
  final int pltQty;
  final String userId;

  const Outbound1FOrderEntity({
    required this.orderNo, // 🚀 추가된 부분
    this.missionType = 2,
    this.pickingArea,
    this.unloadArea,
    required this.startTime,
    required this.pltQty,
    required this.userId,
  });

  @override
  List<Object?> get props => [
        orderNo, // 🚀 추가된 부분
        missionType,
        pickingArea,
        unloadArea,
        startTime,
        pltQty,
        userId,
      ];
}
