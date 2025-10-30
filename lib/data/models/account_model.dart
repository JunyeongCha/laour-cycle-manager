// lib/data/models/account_model.dart
import 'dart:convert';

class Account {
  final String email;
  final String password;

  Account({required this.email, required this.password});

  static List<Account> decode(String accounts) =>
      (json.decode(accounts) as List<dynamic>)
          .map<Account>((item) => Account.fromJson(item))
          .toList();

  factory Account.fromJson(Map<String, dynamic> jsonData) {
    return Account(
      email: jsonData['email'],
      password: jsonData['password'],
    );
  }

  static String encode(List<Account> accounts) => json.encode(
        accounts
            .map<Map<String, dynamic>>((account) => account.toJson())
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}