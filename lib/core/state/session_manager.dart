import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';

enum SessionStatus {
  loggedOut, // 로그아웃 상태
  loggedIn, // 로그인 상태
  expired, // 세션 만료 상태
}

@immutable
class SessionState {
  final SessionStatus status;
  final String? userId;
  final String? userName;
  final int? userCode;

  SessionState({
    this.status = SessionStatus.loggedOut,
    this.userId,
    this.userName,
    this.userCode,
  });

  SessionState copyWith({
    SessionStatus? status,
    String? userId,
    String? userName,
    int? userCode,
  }) {
    return SessionState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userCode: userCode ?? this.userCode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          userId == other.userId &&
          userName == other.userName &&
          userCode == other.userCode);

  @override
  int get hashCode =>
      status.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userCode.hashCode;

  @override
  String toString() {
    return 'SessionState(status: $status, userId: $userId, userName: $userName, userCode: $userCode)';
  }
}

class SessionManagerNotifier extends StateNotifier<SessionState> {
  Timer? _sessionTimer;
  final Duration _sessionTimeout = const Duration(seconds: 10);

  SessionManagerNotifier() : super(SessionState());

  void login({
    required String userId,
    required String userName,
    required int userCode,
  }) {
    state = state.copyWith(
      status: SessionStatus.loggedIn,
      userId: userId,
      userName: userName,
      userCode: userCode,
    );
    startSessionTimer();
  }

  void logout() {
    _sessionTimer?.cancel();
    state = SessionState(status: SessionStatus.loggedOut);
    appLogger.d('로그아웃 완료');
  }

  void _expireSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(status: SessionStatus.expired);
    appLogger.d('세션 타임아웃 / 상태 expired로 변경');
  }

  void startSessionTimer() {
    appLogger.d('세션타이머 시작');
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeout, _expireSession);
  }

  void resetSessionTimer() {
    if (state.status == SessionStatus.loggedIn) startSessionTimer();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}

final sessionManagerProvider =
    StateNotifierProvider<SessionManagerNotifier, SessionState>((ref) {
  return SessionManagerNotifier();
});
