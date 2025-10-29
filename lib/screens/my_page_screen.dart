// lib/screens/my_page_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_template/screens/auth_wrapper.dart';
import 'package:flutter_firebase_template/screens/change_password_screen.dart';
import 'package:flutter_firebase_template/screens/my_info_screen.dart';
import 'package:flutter_firebase_template/screens/theme_screen.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/services/theme_provider.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final iconColor = Provider.of<ThemeProvider>(context, listen: false).iconColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              ListTile(
                leading: Icon(Icons.person_outline, color: iconColor),
                title: const Text('내 정보'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyInfoScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.lock_outline, color: iconColor),
                title: const Text('비밀번호 변경'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
                },
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('다크 모드'),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleThemeMode(value);
                },
                secondary: Icon(Icons.dark_mode_outlined, color: iconColor),
              ),
              ListTile(
                leading: Icon(Icons.color_lens_outlined, color: iconColor),
                title: const Text('테마'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemeScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await authService.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AuthWrapper()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}