// lib/screens/account_selection_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_firebase_template/models/account.dart';
import 'package:flutter_firebase_template/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_template/services/theme_provider.dart';

class AccountSelectionScreen extends StatefulWidget {
  final List<Account> savedAccounts;
  const AccountSelectionScreen({super.key, required this.savedAccounts});
  @override
  State<AccountSelectionScreen> createState() => _AccountSelectionScreenState();
}

class _AccountSelectionScreenState extends State<AccountSelectionScreen> {
  final _storage = const FlutterSecureStorage();

  Future<void> _deleteAccount(Account accountToDelete) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: Text('${accountToDelete.email} 계정을 기기에서 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('삭제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        widget.savedAccounts.removeWhere((acc) => acc.email == accountToDelete.email);
      });
      await _storage.write(
        key: 'saved_accounts',
        value: Account.encode(widget.savedAccounts),
      );
      if (widget.savedAccounts.isEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  void _navigateToLogin({Account? selectedAccount}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(selectedAccount: selectedAccount),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Provider.of<ThemeProvider>(context).iconColor;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.supervisor_account, size: 80, color: iconColor),
                const SizedBox(height: 24),
                Text(
                  '계정 선택',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.savedAccounts.length,
                    itemBuilder: (context, index) {
                      final account = widget.savedAccounts[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: Icon(Icons.person, color: iconColor),
                          title: Text(account.email),
                          onTap: () => _navigateToLogin(selectedAccount: account),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => _deleteAccount(account),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => _navigateToLogin(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('다른 계정으로 로그인'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}