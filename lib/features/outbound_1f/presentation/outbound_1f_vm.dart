class Outbound1FState {
  final bool isLoading;
  final String? errorMessage;
  final List<String> outbound1FMissionList;
  final List<String> outbound1FOrderList;

  Outbound1FState({
    this.isLoading = false,
    this.errorMessage,
    this.outbound1FMissionList = const [],
    this.outbound1FOrderList = const [],
  });

  Outbound1FState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<String>? outbound1FMissionList,
    List<String>? outbound1FOrderList,
  }) {
    return Outbound1FState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      outbound1FMissionList:
      outbound1FMissionList ?? this.outbound1FMissionList,
      outbound1FOrderList: outbound1FOrderList ?? this.outbound1FOrderList,
    );
  }
}
