// SplashScreen: 스플래시 화면 UI를 담당하는 위젯
// 이 화면에서 표시할 내용:
// 1. 중앙에 셀트리온 CI 이미지 (assets/images/celltrion_ci.png)
// 2. 로딩 인디케이터 (초기화 진행 중 표시)
// 3. 초기화 단계별 메시지 (선택적)
// 4. 에러 발생 시 재시도 버튼
// 5. 셀트리온 브랜드 컬러 배경

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';

// TODO: SplashViewModel import 추가
// TODO: Provider 패턴 사용 시 provider import 추가

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 위젯이 빌드된 이후에 초기화 로직을 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    //설정파일로드, 서버통신 확인 등 비동기 초기화 작업 수행
    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      context.go('/login'); // 초기화 완료 후 로그인 페이지로 이동
      // 실제로는 ViewModel을 통해 초기화 상태를 관리하고, 성공 시 로그인
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: 셀트리온 CI 이미지 표시
            Image.asset('assets/images/celltrion_ci.png'),
            const SizedBox(height: 40),
            Text(
              'Celltrion NPDA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.celltrionBlack,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text('초기화 중...'),

            // TODO: ViewModel 상태에 따른 조건부 위젯 렌더링
            // - 로딩 중: CircularProgressIndicator
            // - 에러 발생: 에러 메시지 + 재시도 버튼
            // - 초기화 진행 상황 메시지 표시 (선택적)

            // TODO: Consumer/ChangeNotifierProvider로 ViewModel 상태 구독
          ],
        ),
      ),
    );
  }
}
