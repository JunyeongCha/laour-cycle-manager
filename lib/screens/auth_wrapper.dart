// lib/screens/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_firebase_template/models/account.dart';
import 'package:flutter_firebase_template/screens/home_screen.dart';
import 'package:flutter_firebase_template/screens/account_selection_screen.dart';
import 'package:flutter_firebase_template/screens/login_screen.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/services/theme_provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const LoggedInStateLoader();
        }
        return const LoginRouter();
      },
    );
  }
}

class LoggedInStateLoader extends StatefulWidget {
  const LoggedInStateLoader({super.key});
  @override
  State<LoggedInStateLoader> createState() => _LoggedInStateLoaderState();
}

class _LoggedInStateLoaderState extends State<LoggedInStateLoader> {
  @override
  void initState() {
    super.initState();
    // [핵심 수정] 위젯의 첫 빌드 프레임이 완료된 '직후'에 loadSettings를 호출합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Consumer는 ThemeProvider의 상태 변경을 감지하여 HomeScreen을 다시 그립니다.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return const HomeScreen();
      },
    );
  }
}

class LoginRouter extends StatelessWidget {
  const LoginRouter({super.key});
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
    return FutureBuilder<List<Account>>(
      future: _getSavedAccounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return AccountSelectionScreen(savedAccounts: snapshot.data!);
        } 
        else {
          return const LoginScreen();
        }
      },
    );
  }
}