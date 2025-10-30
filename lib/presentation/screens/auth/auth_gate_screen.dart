// lib/presentation/screens/auth/auth_gate_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/data/models/account_model.dart';
import 'package:laour_cycle_manager/domain/entities/user_profile.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/cycle_list_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/settings/account_selection_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/sign_in_screen.dart';
import 'package:laour_cycle_manager/presentation/view_models/auth_gate_viewmodel.dart';
import 'package:laour_cycle_manager/presentation/view_models/theme_provider.dart';


/// 앱의 가장 첫 관문. 로그인 상태에 따라 적절한 화면으로 안내합니다.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // ViewModel을 사용하여 UI와 비즈니스 로직을 분리합니다.
    return ChangeNotifierProvider(
      create: (_) => getIt<AuthGateViewModel>(),
      child: Consumer<AuthGateViewModel>(
        builder: (context, viewModel, child) {
          // ViewModel이 제공하는 userStream을 사용하여 인증 상태 변경을 감지합니다.
          return StreamBuilder<UserProfile?>(
            stream: viewModel.userStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              
              // 사용자가 로그인되어 있으면,
              if (snapshot.hasData && snapshot.data != null) {
                // 홈 화면으로 가기 전에 테마 등 설정을 로드하는 위젯을 보여줍니다.
                return const _LoggedInStateInitializer();
              }
              
              // 사용자가 로그아웃 상태이면,
              // 저장된 계정이 있는지 확인하는 라우터를 보여줍니다.
              return const _LoginRouter();
            },
          );
        },
      ),
    );
  }
}

/// 로그인 후 상태(테마 등)를 초기화하고 메인 화면으로 이동시키는 위젯
class _LoggedInStateInitializer extends StatefulWidget {
  const _LoggedInStateInitializer();

  @override
  State<_LoggedInStateInitializer> createState() => _LoggedInStateInitializerState();
}

class _LoggedInStateInitializerState extends State<_LoggedInStateInitializer> {
  @override
  void initState() {
    super.initState();
    // 위젯의 첫 빌드 프레임이 완료된 직후에 테마 설정을 불러옵니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    // 테마 로드가 끝나면, 우리가 만들 앱의 메인 화면인 CycleListScreen을 보여줍니다.
    // TODO: 나중에 이 부분을 DashboardScreen으로 변경할 예정입니다.
    return const CycleListScreen();
  }
}

/// 저장된 계정이 있는지 확인하여 로그인 화면 또는 계정 선택 화면으로 안내하는 위젯
class _LoginRouter extends StatelessWidget {
  const _LoginRouter();

  // FlutterSecureStorage에서 저장된 계정 목록을 불러오는 비동기 함수
  Future<List<Account>> _getSavedAccounts() async {
    const storage = FlutterSecureStorage();
    final accountsJson = await storage.read(key: 'saved_accounts');
    if (accountsJson != null && accountsJson.isNotEmpty) {
      return Account.decode(accountsJson);
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    // FutureBuilder를 사용하여 _getSavedAccounts 함수의 결과를 기다립니다.
    return FutureBuilder<List<Account>>(
      future: _getSavedAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // 저장된 계정이 있다면 계정 선택 화면으로 이동합니다.
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return AccountSelectionScreen(savedAccounts: snapshot.data!);
        } 
        // 저장된 계정이 없다면 일반 로그인 화면으로 이동합니다.
        else {
          return const SignInScreen();
        }
      },
    );
  }
}