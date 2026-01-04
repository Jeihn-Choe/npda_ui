import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';
import 'package:npda_ui_flutter/features/login/domain/usecase/login_usecase.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_viewmodel.dart';

import '../../data/repositories/login_repository_mock.dart';
import '../../domain/repositories/login_repository.dart';
import '../state/login_state.dart';

// ============================================================
// 로그인 관련 Provider 정의
// - Repository → UseCase
// - SessionManager는 core/state/session_manager.dart에서 관리
// ============================================================

// 1. repository Provier
/// 로그인 repository IMPL/MOCK 변경
final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  // final apiService = ref.watch(apiServiceProvider);
  // return LoginRepositoryImpl(apiService);

  return LoginRepositoryMock();
});

// 2. UseCase Provider
// Domain계층의 LoginUseCase 생성 및 repository 주입
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return LoginUseCase(repository);
});

// 3. ViewModel Provider
// Presentation계층의 LoginViewModel 생성 및 SessionManager 주입
final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      final sessionManager = ref.watch(sessionManagerProvider.notifier);
      return LoginViewModel(sessionManager);
    });
