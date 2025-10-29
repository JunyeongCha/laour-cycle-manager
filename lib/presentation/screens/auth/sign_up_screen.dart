// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_firebase_template/models/account.dart';
import 'package:flutter_firebase_template/screens/home_screen.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _userIdController = TextEditingController();
  final _dobController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();
  final _storage = const FlutterSecureStorage();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 회원가입 성공 후 로그인 정보 저장 여부를 묻는 대화상자
  Future<bool?> _showSaveCredentialDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그인 정보 저장'),
          content: const Text('회원가입이 완료되었습니다.\n이 기기에 아이디와 비밀번호를 저장하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              child: const Text('아니요'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('예'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  /// 새로운 계정 정보를 기기에 저장하는 함수
  Future<void> _saveAccount(String email, String password) async {
    final accountsJson = await _storage.read(key: 'saved_accounts');
    List<Account> savedAccounts = [];
    if (accountsJson != null && accountsJson.isNotEmpty) {
      savedAccounts = Account.decode(accountsJson);
    }
    savedAccounts.add(Account(email: email, password: password));
    await _storage.write(key: 'saved_accounts', value: Account.encode(savedAccounts));
  }

  /// 회원가입 로직을 처리하는 메인 함수
  Future<void> _signUp() async {
    // Form의 validator들이 모두 통과했는지 확인
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isLoading) return;
    setState(() { _isLoading = true; });

    final error = await _authService.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      displayName: _nameController.text.trim(),
      userId: _userIdController.text.trim(),
      dateOfBirth: _dobController.text.trim(),
    );

    if (!mounted) return;

    if (error == null) { // 회원가입 성공
      final shouldSave = await _showSaveCredentialDialog();
      if (shouldSave == true) {
        await _saveAccount(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }
      // 성공 시 홈 화면으로 바로 이동
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false,
      );
    } else { // 회원가입 실패
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
      );
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '이름 (닉네임)', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? '이름을 입력해주세요.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _userIdController,
                    decoration: const InputDecoration(labelText: '아이디', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? '아이디를 입력해주세요.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dobController,
                    decoration: const InputDecoration(labelText: '생년월일 (예: 1999-01-01)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.datetime,
                    validator: (value) => value!.isEmpty ? '생년월일을 입력해주세요.' : null, // (추후 정규식 검증 추가 가능)
                  ),
                   const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? '이메일을 입력해주세요.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
                    validator: (value) => value!.isEmpty ? '비밀번호를 입력해주세요.' : null,
                  ),
                  // 비밀번호 확인 TextFormField 아래에 추가
                  TextFormField(
                    controller: _targetGoalController, // 새 컨트롤러 필요
                    decoration: const InputDecoration(labelText: '1차 목표 금액'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _signUp,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                          child: const Text('회원가입 완료'),
                        ),
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('이미 계정이 있으신가요? 로그인'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}