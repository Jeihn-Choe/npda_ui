import '../../../../features/status/domain/entities/ev_status_entity.dart';

class EsDto {
  final bool isMainError;
  final bool isSubError;

  EsDto({required this.isMainError, required this.isSubError});

  factory EsDto.fromJson(Map<String, dynamic> json) {
    return EsDto(
      isMainError: json['isMainError'] as bool? ?? false,
      isSubError: json['isSubError'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isMainError': isMainError,
      'isSubError': isSubError,
    };
  }

  // ✨ Feature Entity로 변환
  EvStatusEntity toEntity() {
    return EvStatusEntity(
      isMainError: isMainError,
      isSubError: isSubError,
    );
  }
}