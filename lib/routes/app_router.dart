// lib/routes/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/auth_gate_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/add_new_cycle_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/cycle_detail_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/cycle_list_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/sign_in_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/settings/my_page_screen.dart';

// 앱의 모든 화면 경로를 관리하는 라우터 설정입니다.
final GoRouter router = GoRouter(
  // 앱이 처음 시작될 때 보여줄 경로
  initialLocation: '/', 
  routes: [
    // 루트 경로 ('/'): 앱의 시작점. AuthGate가 로그인 상태를 확인합니다.
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    // 로그인 화면 경로
    GoRoute(
      path: '/signIn',
      builder: (context, state) => const SignInScreen(),
    ),
    // 사이클 목록 화면 경로 (로그인 후 보여줄 메인 화면 중 하나)
    GoRoute(
      path: '/cycleList',
      builder: (context, state) => const CycleListScreen(),
    ),
    // [추가] 새 사이클 추가 화면 경로
    GoRoute(
      path: '/addCycle',
      builder: (context, state) => const AddNewCycleScreen(),
    ),
    // [추가] 사이클 상세 화면 경로
    // 예: '/cycleDetail/CYCLE_OBJECT' 처럼 객체를 전달받아 화면을 구성합니다.
    GoRoute(
      path: '/cycleDetail',
      builder: (context, state) {
        // state.extra를 통해 이전 화면에서 전달받은 Cycle 객체를 가져옵니다.
        final cycle = state.extra as Cycle;
        return CycleDetailScreen(cycle: cycle);
      },
    ),
    // [추가] 마이페이지(설정) 화면 경로
    GoRoute(
      path: '/myPage',
      builder: (context, state) => const MyPageScreen(),
    ),
  ],
);