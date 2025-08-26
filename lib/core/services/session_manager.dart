import 'dart:async';

import 'package:flutter/widgets.dart';

class SessionManager with WidgetsBindingObserver {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  SessionManager._internal() {
    WidgetsBinding.instance.addObserver(this);
  }

  DateTime? _lastActiveTime;
  Timer? _sessionTimer;
  final Duration _sessionTimeout = const Duration(minutes: 30); // 세션 타임

  // 세션 만료 콜백
  VoidCallback? onSessionExpired;

  // 세션 시작
  void startSession() {
    _updateLastActiveTime();
    _startSessionMonitoring();
  }

  // 사용자 활동 업데이트
  void updateActivity() {
    _updateLastActiveTime();
  }

  // 세션 종료
  void stopSession() {
    _sessionTimer?.cancel();
    _lastActiveTime = null;
  }

  // 세션 만료 여부 확인
  bool get isSessionExpired {
    // 마지막 활동 시간이 없으면 세션 만료로 간주
    if (_lastActiveTime == null) return true;
    // 현재 시간과 마지막 활동 시간의 차이가 세션 타임아웃을 초과하는지 확인
    return DateTime.now().difference(_lastActiveTime!) > _sessionTimeout;
  }

  // 마지막 활동시간 감지해서 lastActiveTime 업데이트
  void _updateLastActiveTime() {
    _lastActiveTime = DateTime.now();
  }

  // 세션 모니터링 시작
  void _startSessionMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      if (isSessionExpired) {
        onSessionExpired?.call();
        stopSession();
        timer.cancel();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (isSessionExpired && _lastActiveTime != null) {
          onSessionExpired?.call();
          stopSession();
        }
        break;

      case AppLifecycleState.paused:
      // 앱이 백그라운드로 갔을 때 마지막 활동 시간 업데이트
      case AppLifecycleState.inactive:
        updateActivity();
        break;

      default:
        break;
    }
  }

  void dispose() {
    _sessionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }
}
