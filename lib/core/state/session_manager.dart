import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/config/app_config.dart';
import 'package:npda_ui_flutter/features/login/domain/entities/login_result.dart';
import 'package:npda_ui_flutter/features/login/domain/repositories/login_repository.dart';
import 'package:npda_ui_flutter/features/login/domain/usecase/login_usecase.dart';
import 'package:npda_ui_flutter/features/login/presentation/providers/login_providers.dart';

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
      status.hashCode ^ userId.hashCode ^ userName.hashCode ^ userCode.hashCode;

  @override
  String toString() {
    return 'SessionState(status: $status, userId: $userId, userName: $userName, userCode: $userCode)';
  }
}

class SessionManagerNotifier extends StateNotifier<SessionState> {
  final LoginUseCase _loginUseCase;
  final LoginRepository _loginRepository;
  Timer? _sessionTimer;
  final Duration _sessionTimeout = const Duration(minutes: 1);

  SessionManagerNotifier(this._loginUseCase, this._loginRepository)
    : super(SessionState());

  /// 로그인 로직 수행 (UseCase 호출 포함)
  Future<LoginResult> login(String userId, String password) async {
    /// UseCase 호출
    final result = await _loginUseCase(userId, password);

    if (result.isSuccess) {
      // 세션 상태 업데이트
      state = state.copyWith(
        status: SessionStatus.loggedIn,
        userId: result.userId!,
        userName: result.userName!,
        userCode: result.userCode!,
      );
      startSessionTimer();
    }

    return result;
  }

  /// 로그아웃 (서버에 로그아웃 알림)
  Future<void> logout() async {
    final userId = state.userId;

    // 서버에 로그아웃 요청
    if (userId != null && userId.isNotEmpty) {
      await _loginRepository.logout(userId, 'logout', ApiConfig.logoutEndpoint);
    }

    _sessionTimer?.cancel();
    state = SessionState(status: SessionStatus.loggedOut);
  }

  /// 세션 만료 (서버에 만료 알림)
  Future<void> _expireSession() async {
    final userId = state.userId;

    // 서버에 세션 만료 알림
    if (userId != null && userId.isNotEmpty) {
      await _loginRepository.logout(
        userId,
        'sessionExpired',
        ApiConfig.sessionExpiredEndpoint,
      );
    }

    _sessionTimer?.cancel();
    state = state.copyWith(status: SessionStatus.expired);
  }

  void startSessionTimer() {
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

// ============================================================
// SessionManager Provider
// - LoginUseCase를 주입받아 로그인 로직 관리
// - LoginRepository를 주입받아 로그아웃 처리
// ============================================================
final sessionManagerProvider =
    StateNotifierProvider<SessionManagerNotifier, SessionState>((ref) {
      // LoginUseCase를 주입받아 SessionManager 생성
      // loginUseCaseProvider는 features/login/presentation/providers/login_providers.dart에 정의됨
      final loginUseCase = ref.watch(loginUseCaseProvider);
      final loginRepository = ref.watch(loginRepositoryProvider);
      return SessionManagerNotifier(loginUseCase, loginRepository);
    });
