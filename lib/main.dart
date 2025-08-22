import 'package:flutter/material.dart';

import 'core/routes/router.dart';

// TODO: SplashScreen import 추가
// TODO: AppTheme import 추가 (core/themes/app_theme.dart)
// TODO: 라우팅 관련 패키지 import (go_router, auto_route 등)

void main() {
  // TODO: 필요한 초기 설정 추가
  // - WidgetsFlutterBinding.ensureInitialized() (비동기 초기화 시)
  // - 의존성 주입 설정 (GetIt, Provider 등)
  // - 에러 핸들링 설정
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Celltrion NPDA',
      
      routerConfig: router,

      // TODO: 라우팅 설정 추가
      // - /splash (초기 화면)
      // - /login (로그인 화면)
      // - /main (메인 화면)
      // routes: AppRouter.routes,
      // initialRoute: '/splash',
    );
  }
}
