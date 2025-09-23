import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScanEventService {
  final _scannedDataController = StreamController<String>.broadcast();

  Stream<String> get scannedDataStream => _scannedDataController.stream;

  final _buffer = StringBuffer();
  Timer? _debounceTimer;

  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.character != null && event.character!.isNotEmpty) {
        _buffer.write(event.character);
        _debounceTimer?.cancel();
        _debounceTimer = Timer(
          const Duration(milliseconds: 100),
          _processBuffer,
        );
      } else if (event.logicalKey == LogicalKeyboardKey.enter) {
        _processBuffer();
      }
    }
  }

  void _processBuffer() {
    if (_buffer.isNotEmpty) {
      final scannedData = _buffer.toString();
      _scannedDataController.add(scannedData);
      _buffer.clear();
    }
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  void dispose() {
    _scannedDataController.close();
    _debounceTimer?.cancel();
  }
}

final scanEventServiceProvider = Provider<ScanEventService>((ref) {
  final service = ScanEventService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// provider 스캔 데이터 스트림 노출
final scannedDataStreamProvider = StreamProvider<String>((ref) {
  final scanEventService = ref.watch(scanEventServiceProvider);
  return scanEventService.scannedDataStream;
});
