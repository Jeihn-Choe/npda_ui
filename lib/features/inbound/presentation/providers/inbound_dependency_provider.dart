// lib/features/inbound/presentation/providers/inbound_dependency_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/features/inbound/data/repositories/inbound_po_repository_impl.dart';
import 'package:npda_ui_flutter/features/inbound/data/repositories/inbound_sm_repository_impl.dart';
import 'package:npda_ui_flutter/features/inbound/domain/repositories/inbound_po_repository.dart';
import 'package:npda_ui_flutter/features/inbound/domain/repositories/inbound_sm_repository.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/inbound_order_usecase.dart';

import '../../../../core/data/repositories/mqtt/mqtt_stream_repository.dart';

// [UseCase]
final inboundOrderUseCaseProvider = Provider<InboundOrderUseCase>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return InboundOrderUseCase(repository);
});

// [Repository] - Mock/Real 교체 지점

/// 1. Inbound SM Repository
final inboundMissionRepositoryProvider = Provider<InboundSmRepository>((ref) {
  // Impl
  final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
  return InboundSmRepositoryImpl(mqttStreamRepository);

  // Mock
  // return MockInboundSmRepository();
});

/// 2. Inbound PO Repository
final inboundPoRepositoryProvider = Provider<InboundPoRepository>((ref) {
  // Impl
  final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
  return InboundPoRepositoryImpl(mqttStreamRepository);

  // Mock
  // return MockInboundPoRepository();
});
