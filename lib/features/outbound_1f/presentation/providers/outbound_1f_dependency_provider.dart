import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/data/repositories/mqtt/mqtt_stream_repository.dart';
import 'package:npda_ui_flutter/features/outbound_1f/data/repositories/outbound_1f_mission_repository_impl.dart';
// ✨ 제거: 불필요한 import 제거
// import '../../../../core/providers/repository_providers.dart';

// ✨ 추가: Repository 관련 임포트
import 'package:npda_ui_flutter/features/outbound_1f/domain/repositories/outbound_1f_mission_repository.dart';

// ✨ 추가: Outbound1FMissionRepository 제공자
final outbound1fMissionRepositoryProvider =
    Provider<Outbound1FMissionRepository>((ref) {
      final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
      return Outbound1FMissionRepositoryImpl(mqttStreamRepository);
    });
