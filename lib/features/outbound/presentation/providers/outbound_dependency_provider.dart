// lib/features/outbound/presentation/providers/outbound_dependency_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/outbound/data/repositories/outbound_po_repository_impl.dart';
import 'package:npda_ui_flutter/features/outbound/data/repositories/outbound_sm_repository_impl.dart';
import 'package:npda_ui_flutter/features/outbound/domain/repositories/outbound_po_repository.dart';
import 'package:npda_ui_flutter/features/outbound/domain/repositories/outbound_sm_repository.dart';

import '../../../../core/data/repositories/mqtt/mqtt_stream_repository.dart';
import '../../domain/usecases/outbound_order_usecase.dart';

/// [Repository] - Mock/Real 교체 지점

// 1. Outbound Mission (SM) Repository
final outboundSmRepositoryProvider = Provider<OutboundSmRepository>((ref) {
  // Impl
  final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
  return OutboundSmRepositoryImpl(mqttStreamRepository);

  // Mock
  // return MockOutboundSmRepository();
});

// 2. Outbound PO Repository
final outboundPoRepositoryProvider = Provider<OutboundPoRepository>((ref) {
  // Impl
  final mqttStreamRepository = ref.watch(mqttStreamRepositoryProvider);
  return OutboundPoRepositoryImpl(mqttStreamRepository);

  // Mock
  // return MockOutboundPoRepository();
});

final outboundOrderUseCaseProvider = Provider<OutboundOrderUseCase>((ref) {
  return OutboundOrderUseCase(ref);
});
