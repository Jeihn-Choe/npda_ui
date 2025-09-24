import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';

import '../data/repositories/mission_repository_impl.dart';
import '../network/http/api_provider.dart';

/// 앱 전역에서 MissionRepository를 제공하는 Provider
final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);

  return MissionRepositoryImpl(apiService);
});
