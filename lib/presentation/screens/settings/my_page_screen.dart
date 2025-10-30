// lib/presentation/screens/settings/my_page_screen.dart

import 'package:flutter/material.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/auth_gate_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/settings/change_password_screen.dart'; // [추가] 비밀번호 변경 화면 임포트
import 'package:laour_cycle_manager/presentation/screens/settings/my_info_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/settings/theme_screen.dart';
import 'package:laour_cycle_manager/presentation/view_models/settings_viewmodel.dart';
import 'package:provider/provider.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SettingsViewModel>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('마이페이지'),
        ),
        body: Consumer<SettingsViewModel>(
          builder: (context, viewModel, child) {
            return ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('내 정보'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyInfoScreen()),
                    );
                  },
                ),
                // [복원] 비밀번호 변경 메뉴
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('비밀번호 변경'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.color_lens_outlined),
                  title: const Text('테마 설정'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ThemeScreen()),
                    );
                  },
                ),
                const Divider(),
                // [ViewModel 연결] 로그아웃 버튼
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
                  enabled: !viewModel.isLoading,
                  onTap: () async {
                    await viewModel.signOut();
                    
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const AuthGate()),
                        (route) => false,
                      );
                    }
                  },
                ),
                if (viewModel.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}