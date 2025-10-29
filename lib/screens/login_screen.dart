// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_firebase_template/models/account.dart';
import 'package:flutter_firebase_template/screens/signup_screen.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_template/services/theme_provider.dart';
import 'package:flutter_firebase_template/screens/auth_wrapper.dart'; // [추가]

class LoginScreen extends StatefulWidget {
  final Account? selectedAccount;
  const LoginScreen({super.key, this.selectedAccount});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();

  bool _isLoading = false;
  List<Account> _savedAccounts = [];

  @override
  void initState() {
    super.initState();
    if (widget.selectedAccount != null) {
      _emailController.text = widget.selectedAccount!.email;
      _passwordController.text = widget.selectedAccount!.password;
    }
    _loadSavedAccounts();
  }

  Future<void> _loadSavedAccounts() async {
    final accountsJson = await _storage.read(key: 'saved_accounts');
    if (mounted && accountsJson != null && accountsJson.isNotEmpty) {
      setState(() {
        _savedAccounts = Account.decode(accountsJson);
      });
    }
  }

  Future<void> _saveOrUpdateAccount(String email, String password) async {
    final existingAccountIndex = _savedAccounts.indexWhere((acc) => acc.email == email);
    if (existingAccountIndex != -1) {
      _savedAccounts[existingAccountIndex] = Account(email: email, password: password);
    } else {
      _savedAccounts.add(Account(email: email, password: password));
    }
    await _storage.write(
      key: 'saved_accounts',
      value: Account.encode(_savedAccounts),
    );
  }

  Future<bool?> _showSaveCredentialDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그인 정보 저장'),
          content: const Text('이 기기에 아이디와 비밀번호를 저장하시겠습니까?'),
          actions: <Widget>[
            TextButton(child: const Text('아니요'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(child: const Text('예'), onPressed: () => Navigator.of(context).pop(true)),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final error = await _authService.signInWithEmail(email: email, password: password);

    if (!mounted) return;

    if (error == null) {
      final accountIndex = _savedAccounts.indexWhere((acc) => acc.email == email);
      if (accountIndex == -1) {
        final shouldSave = await _showSaveCredentialDialog();
        if (shouldSave == true) {
          await _saveOrUpdateAccount(email, password);
        }
      } else {
        if (_savedAccounts[accountIndex].password != password) {
          await _saveOrUpdateAccount(email, password);
        }
      }
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    }
    if(mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Provider.of<ThemeProvider>(context).iconColor;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.lock_open, size: 80, color: iconColor),
                const SizedBox(height: 48),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 32),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: _login,
                        child: const Text('로그인'),
                      ),
                TextButton(
                  onPressed: _isLoading ? null : () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                  child: const Text('계정이 없으신가요? 회원가입'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}