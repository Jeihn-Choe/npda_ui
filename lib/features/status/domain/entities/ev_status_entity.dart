class EvStatusEntity {
  final bool isMainError;
  final bool isSubError;

  const EvStatusEntity({required this.isMainError, required this.isSubError});

  factory EvStatusEntity.initial() {
    return const EvStatusEntity(isMainError: false, isSubError: false);
  }

  EvStatusEntity copyWith({bool? isMainError, bool? isSubError}) {
    return EvStatusEntity(
      isMainError: isMainError ?? this.isMainError,
      isSubError: isSubError ?? this.isSubError,
    );
  }
}
