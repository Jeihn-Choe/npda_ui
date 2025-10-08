import 'package:equatable/equatable.dart';

class Outbound1FOrderEntity extends Equatable {
  final String? pickingArea;
  final String? unloadArea;
  final DateTime startTime;
  final int pltQty;
  final String userId;

  Outbound1FOrderEntity({
    this.pickingArea,
    this.unloadArea,
    required this.startTime,
    required this.pltQty,
    required this.userId,
  });

  @override
  List<Object?> get props => [
    pickingArea,
    unloadArea,
    startTime,
    pltQty,
    userId,
  ];
}
