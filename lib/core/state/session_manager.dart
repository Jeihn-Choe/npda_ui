import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';

// 🚀 추가된 부분: 세션 상태를 명확하게 표현하기 위한 enum
enum SessionStatus {
  loggedOut, // 로그아웃 상태
  loggedIn, // 로그인 상태
  expired, // 세션 만료 상태
}

@immutable
class SessionState {
  // ✨ 변경된 부분: isLoggedIn(bool) -> status(enum)
  final SessionStatus status;
  final String? userId;
  final String? userName;
  final int? userCode;

  // ✨ 변경된 부분: 기본 상태를 loggedOut으로 설정
  SessionState({
    this.status = SessionStatus.loggedOut,
    this.userId,
    this.userName,
    this.userCode,
  });

  // ✨ 변경된 부분: isLoggedIn 제거, status 추가
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
          // ✨ 변경된 부분
          status == other.status &&
          userId == other.userId &&
          userName == other.userName &&
          userCode == other.userCode);

  @override
  int get hashCode =>
      // ✨ 변경된 부분
      status.hashCode ^ userId.hashCode ^ userName.hashCode ^ userCode.hashCode;

  @override
  String toString() {
    // ✨ 변경된 부분
    return 'SessionState(status: $status, userId: $userId, userName: $userName, userCode: $userCode)';
  }
}

class SessionManagerNotifier extends StateNotifier<SessionState> {
  Timer? _sessionTimer;

  // TODO: 세션 시간은 실제 운영 환경에 맞게 조절 필요
  final Duration _sessionTimeout = const Duration(seconds: 10);

  SessionManagerNotifier() : super(SessionState());

  void login({
    required String userId,
    required String userName,
    required int userCode,
  }) {
    state = state.copyWith(
      // ✨ 변경된 부분
      status: SessionStatus.loggedIn,
      userId: userId,
      userName: userName,
      userCode: userCode,
    );

    startSessionTimer();
  }

  void logout() {
    _sessionTimer?.cancel();
    // ✨ 변경된 부분: 상태를 명시적으로 loggedOut으로 설정
    state = SessionState(status: SessionStatus.loggedOut);
    appLogger.d('로그아웃 완료');
  }

  // 🚀 추가된 부분: 세션 만료 처리 전용 함수
  void _expireSession() {
    _sessionTimer?.cancel();
    state = state.copyWith(status: SessionStatus.expired);
    appLogger.d('세션 타임아웃 / 상태 expired로 변경');
    // 🚀 추가: 변경 직후의 상태를 로그로 출력
    appLogger.d('변경된 최종 상태: $state');
  }

  void startSessionTimer() {
    appLogger.d('세션타이머 시작');
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeout, () {
      // ✨ 변경된 부분: logout() -> _expireSession() 호출
      _expireSession();
    });
  }

  void resetSessionTimer() {
    // ✨ 변경된 부분: isLoggedIn -> status 체크
    if (state.status == SessionStatus.loggedIn) startSessionTimer();
    appLogger.d('세션타이머 리셋');
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
