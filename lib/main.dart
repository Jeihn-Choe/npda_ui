import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/routes/router.dart';
import 'package:npda_ui_flutter/core/themes/app_theme.dart';

// TODO: SplashScreen import 추가
// TODO: AppTheme import 추가 (core/themes/app_theme.dart)
// TODO: 라우팅 관련 패키지 import (go_router, auto_route 등)

void main() {
  // TODO: 필요한 초기 설정 추가
  WidgetsFlutterBinding.ensureInitialized();

  // - 의존성 주입 설정 (GetIt, Provider 등)
  // - 에러 핸들링 설정

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      title: 'Celltrion NPDA',
      theme: AppTheme.lightTheme,
    );
  }
}
