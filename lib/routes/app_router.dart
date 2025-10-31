// lib/routes/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:laour_cycle_manager/domain/entities/cycle.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/auth_gate_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/add_new_cycle_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/cycle_detail_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/cycle_list_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/sign_in_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/settings/my_page_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/signIn',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/cycleList',
      builder: (context, state) => const CycleListScreen(),
    ),
    GoRoute(
      path: '/addCycle',
      builder: (context, state) => const AddNewCycleScreen(),
    ),
    // [수정] Cycle 객체를 전달받아 CycleDetailScreen을 생성하도록 변경
    GoRoute(
      path: '/cycleDetail',
      builder: (context, state) {
        // state.extra를 통해 이전 화면에서 전달받은 Cycle 객체를 가져옵니다.
        final cycle = state.extra as Cycle;
        return CycleDetailScreen(cycle: cycle);
      },
    ),
    GoRoute(
      path: '/myPage',
      builder: (context, state) => const MyPageScreen(),
    ),
  ],
);