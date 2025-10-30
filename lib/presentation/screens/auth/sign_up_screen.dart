// lib/presentation/screens/auth/sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/auth_gate_screen.dart';
import 'package:laour_cycle_manager/presentation/view_models/sign_up_viewmodel.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<SignUpViewModel>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('회원가입')),
        body: const SignUpForm(),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _targetGoalController = TextEditingController(); // 1차 목표 금액 컨트롤러

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _targetGoalController.dispose();
    super.dispose();
  }

  /// 회원가입 성공 후 로그인 정보 저장 여부를 묻는 대화상자 (템플릿 기능 유지)
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

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SignUpViewModel>(context);

    return SafeArea(
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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                  validator: (value) => (value == null || !value.contains('@')) ? '유효한 이메일을 입력해주세요.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.length < 6) ? '비밀번호는 6자 이상이어야 합니다.' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '비밀번호 확인', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetGoalController,
                  decoration: const InputDecoration(labelText: '1차 목표 금액 (숫자만 입력)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                     if (value == null || value.isEmpty || double.tryParse(value) == null) {
                      return '올바른 숫자 형식으로 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                if (viewModel.getErrorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      viewModel.getErrorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                viewModel.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final email = _emailController.text.trim();
                            final password = _passwordController.text.trim();

                            final success = await viewModel.signUp(
                              email: email,
                              password: password,
                              name: _nameController.text.trim(),
                              targetGoal: _targetGoalController.text.trim(),
                            );
                            
                            if (success && mounted) {
                              final shouldSave = await _showSaveCredentialDialog();
                              if (shouldSave == true) {
                                await viewModel.saveCredentials(email: email, password: password);
                              }
                              if (mounted) {
                                // 성공 시, 모든 이전 화면을 없애고 AuthGate로 이동하여 자동으로 로그인되게 합니다.
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const AuthGate()),
                                  (route) => false,
                                );
                              }
                            }
                          }
                        },
                        child: const Text('회원가입 완료'),
                      ),
                TextButton(
                  onPressed: viewModel.isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('이미 계정이 있으신가요? 로그인'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}