import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';

import '../features/login/presentation/providers/login_providers.dart';

class MainShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginViewModelProvider);

    return DefaultTabController(
      length: (3),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.grey200,
          toolbarHeight: 15,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                style: TextStyle(
                  color: AppColors.celltrionBlack,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
                'RCS 연동 NPDA',
              ),
              Text(
                style: TextStyle(
                  color: AppColors.darkGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                '${loginState.userId} ${loginState.userName}님',
              ),
            ],
          ),
          bottom: TabBar(
            tabs: [
              Tab(text: '입고'),
              Tab(text: '출고'),
              Tab(text: '1층출고'),
            ],
            //탭이 선택될 때 GoRouter의 브랜치 변경
            onTap: (index) => _onTap(context, index),
          ),
        ),
        // 탭에 따라 다른 화면을 보여주는 Shell
        body: navigationShell,
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      // 현재 탭을 다시 탭해도 화면이 새로고침되지 않도록 설정
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
