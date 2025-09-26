import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/usecase_providers.dart';

final initializeAppProvider = FutureProvider<void>((ref) async {
  ref.read(mqttMessageRouterUseCaseProvider);
});
