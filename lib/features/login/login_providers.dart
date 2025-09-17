// // Provider 정의 //
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:npda_ui_flutter/features/login/presentation/login_viewmodel.dart';
//
// /// Data 계층의 Repository를 제공하는 Provider
// // final loginRepositoryProvider = Provider<LoginRepository>((ref) {
// /// core에서 관리되는 apiServiceProvider를 참조(watch)합니다.
// // final apiService = ref.watch(apiServiceProvider);
//
// /// LoginRepositoryImpl을 생성하여 LoginRepository 타입으로 반환합니다.
// // return LoginRepositoryImpl(apiService);
// ///});
//
// /// Domain 계층의 UseCase를 제공하는 Provider
// // final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
// //   // 위에서 정의한 loginRepositoryProvider를 참조합니다.
// //   final loginRepository = ref.watch(loginRepositoryProvider);
//
// //   return LoginUseCase(loginRepository);
// // });
//
// /// Presentation 계층의 ViewModel을 제공하는 Provider
// final loginViewModelProvider =
//     StateNotifierProvider<LoginViewModel, LoginState>((ref) {
//       // 위에서 정의한 loginUseCaseProvider를 참조합니다.
//       final loginUseCase = ref.watch(loginUseCaseProvider);
//
//       return LoginViewModel(loginUseCase);
//     });
