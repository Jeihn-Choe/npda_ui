import 'package:flutter_riverpod/flutter_riverpod.dart';

// ✨ 제거: 불필요한 import 제거

final initializeAppProvider = FutureProvider<void>((ref) async {
  // ✨ 제거: mqttMessageRouterUseCaseProvider 참조 제거
  // ref.read(mqttMessageRouterUseCaseProvider);
});
