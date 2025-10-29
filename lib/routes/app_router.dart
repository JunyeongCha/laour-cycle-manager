// lib/routes/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/auth_gate_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/cycle_list_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/sign_in_screen.dart';

// 앱의 모든 화면 경로를 관리하는 라우터 설정입니다.
// GoRouter를 사용하면 웹사이트 주소처럼 경로를 깔끔하게 관리할 수 있습니다.
final GoRouter router = GoRouter(
  initialLocation: '/', // 앱이 처음 시작될 때 보여줄 경로
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
    // TODO: 앞으로 만들 화면들의 경로를 여기에 계속 추가할 예정입니다.
    // 예: '/cycleDetail/:cycleId', '/addCycle', '/settings' 등
  ],
);