// lib/presentation/screens/auth/sign_in_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package.laour_cycle_manager/config/dependency_injection.dart';
import 'package:laour_cycle_manager/data/models/account_model.dart';
import 'package:laour_cycle_manager/presentation/screens/auth/sign_up_screen.dart';
import 'package:laour_cycle_manager/presentation/screens/cycle_management/cycle_list_screen.dart';
import 'package:laour_cycle_manager/presentation/view_models/sign_in_viewmodel.dart';
import 'package:provider/provider.dart';

// ViewModel을 사용하므로 StatefulWidget 대신 StatelessWidget으로 변경하여 구조를 단순화합니다.
class SignInScreen extends StatelessWidget {
  // 계정 선택 화면에서 특정 계정을 선택했을 때 그 정보를 받아오기 위한 파라미터입니다.
  final Account? selectedAccount;

  const SignInScreen({super.key, this.selectedAccount});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider를 사용하여 DI 컨테이너에서 SignInViewModel 인스턴스를 생성하고 제공합니다.
    return ChangeNotifierProvider(
      create: (_) => getIt<SignInViewModel>(),
      child: Scaffold(
        // AppBar는 제거하여 템플릿의 디자인과 유사하게 만듭니다.
        body: SafeArea(
          // selectedAccount 정보를 SignInForm에 전달합니다.
          child: SignInForm(selectedAccount: selectedAccount),
        ),
      ),
    );
  }
}

// 실제 UI 폼은 StatefulWidget으로 유지하여 TextEditingController 등을 관리합니다.
class SignInForm extends StatefulWidget {
  final Account? selectedAccount;
  const SignInForm({super.key, this.selectedAccount});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때, selectedAccount 정보가 있으면 폼을 미리 채웁니다.
    if (widget.selectedAccount != null) {
      _emailController.text = widget.selectedAccount!.email;
      _passwordController.text = widget.selectedAccount!.password;
    }
  }

  // 로그인 정보 저장 여부를 묻는 다이얼로그 (템플릿 기능 유지)
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of를 사용하여 ViewModel에 접근합니다.
    final viewModel = Provider.of<SignInViewModel>(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_open, size: 80),
              const SizedBox(height: 48),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                validator: (value) => (value == null || value.isEmpty) ? '이메일을 입력해주세요.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
                 validator: (value) => (value == null || value.isEmpty) ? '비밀번호를 입력해주세요.' : null,
              ),
              const SizedBox(height: 24),
              // ViewModel에 에러 메시지가 있으면 화면에 표시합니다.
              if (viewModel.getErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    viewModel.getErrorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              // ViewModel의 로딩 상태에 따라 버튼 또는 로딩 인디케이터를 보여줍니다.
              viewModel.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final email = _emailController.text;
                          final password = _passwordController.text;

                          // ViewModel의 로그인 함수를 호출합니다.
                          final result = await viewModel.signIn(email: email, password: password);

                          if (!mounted) return;

                          // 로그인 성공 시
                          if (result == SignInResult.success) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const CycleListScreen()),
                              (route) => false,
                            );
                          } 
                          // 로그인 성공 & 정보 저장이 필요할 시
                          else if (result == SignInResult.successAndAskToSave) {
                              final shouldSave = await _showSaveCredentialDialog();
                              if (shouldSave == true) {
                                // ViewModel에 정보 저장을 요청합니다.
                                await viewModel.saveCredentials(email: email, password: password);
                              }
                              if(mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => const CycleListScreen()),
                                  (route) => false,
                                );
                              }
                          }
                        }
                      },
                      child: const Text('로그인'),
                    ),
              TextButton(
                onPressed: viewModel.isLoading ? null : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignUpScreen()),
                        );
                      },
                child: const Text('계정이 없으신가요? 회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}