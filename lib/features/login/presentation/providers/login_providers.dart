import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/login/domain/usecase/login_usecase.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_viewmodel.dart';

import '../../../../core/network/http/api_provider.dart';
import '../../data/repositories/login_repository_impl.dart';
import '../../domain/repositories/login_repository.dart';
import '../state/login_state.dart';

// 1. repository Provier
// Data계층의 LoginRepositoryImpl 생성 및 Domain계층의 LoginRepository 인터페이스 주입

final loginRepositoryProvider = Provider<LoginRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LoginRepositoryImpl(apiService);
});

// 2. UseCase Provider
// Domain계층의 LoginUseCase 생성 및 repository 주입
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(loginRepositoryProvider);
  return LoginUseCase(repository);
});

// 3. ViewModel Provider
// Presentation계층의 LoginViewModel 생성 및 usecase 주입
final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, LoginState>((ref) {
      final loginUseCase = ref.watch(loginUseCaseProvider);
      return LoginViewModel(loginUseCase);
    });
