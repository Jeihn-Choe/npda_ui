import 'package:npda_ui_flutter/core/domain/entities/request_order_entity.dart';

class RequestOrderDto {
  final String cmdId;
  final List<RequestOrderEntity> requestOrders;

  const RequestOrderDto({required this.cmdId, required this.requestOrders});

  Map<String, dynamic> toJson() {
    return {
      'cmdId': cmdId,
      'payload': requestOrders.map((entity) {
        return {
          'missionType': entity.missionType,
          'huId': entity.pltNo,
          'doNo': entity.doNo,
          'startTime': entity.startTime?.toIso8601String(),
          'targetRackLevel': entity.targetRackLevel,
          'employeeId': entity.employeeId,
          'sourceBin': entity.sourceBin,
          'destinationBin': entity.destinationBin,
          'isWrapped': entity.isWrapped,
          'destinationArea': entity.destinationArea,
          'pltQty': entity.pltQty,
        };
      }).toList(),
    };
  }
}

class ResponseOrderDto {
  final String? cmdId;
  final String? result;
  final String? msg;

  ResponseOrderDto({this.cmdId, this.result, this.msg});

  factory ResponseOrderDto.fromJson(Map<String, dynamic> json) {
    return ResponseOrderDto(
      cmdId: json['cmdId'] as String?,
      result: json['result'] as String?,
      msg: json['msg'] as String?,
    );
  }
}
