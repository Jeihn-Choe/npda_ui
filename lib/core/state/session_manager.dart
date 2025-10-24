import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';

@immutable
class SessionState {
  final bool isLoggedIn;
  final String? userId;
  final String? userName;
  final int? userCode;

  SessionState({
    this.isLoggedIn = false,
    this.userId,
    this.userName,
    this.userCode,
  });

  SessionState copyWith({
    bool? isLoggedIn,
    String? userId,
    String? userName,
    int? userCode,
  }) {
    return SessionState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
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
          isLoggedIn == other.isLoggedIn &&
          userId == other.userId &&
          userName == other.userName &&
          userCode == other.userCode);

  @override
  int get hashCode =>
      isLoggedIn.hashCode ^
      userId.hashCode ^
      userName.hashCode ^
      userCode.hashCode;

  @override
  String toString() {
    return 'SessionState(isLoggedIn: $isLoggedIn, userId: $userId, userName: $userName, userCode: $userCode)';
  }
}

class SessionManagerNotifier extends StateNotifier<SessionState> {
  Timer? _sessionTimer;
  final Duration _sessionTimeout = const Duration(minutes: 1);

  SessionManagerNotifier() : super(SessionState());

  void login({
    required String userId,
    required String userName,
    required int userCode,
  }) {
    state = state.copyWith(
      isLoggedIn: true,
      userId: userId,
      userName: userName,
      userCode: userCode,
    );

    startSessionTimer();
  }

  void logout() {
    _sessionTimer?.cancel();
    state = SessionState();
    appLogger.d('로그아웃 완료');
    // TODO: GoRouter 이용해서 로그인 화면으로 리디렉션해야함.
  }

  void startSessionTimer() {
    appLogger.d('세션타이머 시작');
    _sessionTimer?.cancel();
    _sessionTimer = Timer(_sessionTimeout, () {
      appLogger.d('세션 타임 아웃 / 로그아웃처리');
      logout();
    });
    appLogger.d('세션타이머 재시작');
  }

  void resetSessionTimer() {
    if (state.isLoggedIn) startSessionTimer();
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
