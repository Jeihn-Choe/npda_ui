import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Inbound Viewmodel에서 관리하는 상태들 모음
class InboundState {
  final String pltNo = '';
  final DateTime workStartTime = DateTime.now();
}

class InboundViewModel extends StateNotifier<InboundState> {
  InboundViewModel() : super(InboundState());
}
