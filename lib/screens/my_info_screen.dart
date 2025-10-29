// lib/screens/my_info_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_template/services/auth_service.dart';
import 'package:flutter_firebase_template/services/firestore_service.dart';
import 'package:flutter_firebase_template/services/theme_provider.dart';

class MyInfoScreen extends StatefulWidget {
  const MyInfoScreen({super.key});

  @override
  State<MyInfoScreen> createState() => _MyInfoScreenState();
}

class _MyInfoScreenState extends State<MyInfoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  late Future<DocumentSnapshot<Map<String, dynamic>>> _userInfoFuture;

  @override
  void initState() {
    super.initState();
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _userInfoFuture = _firestoreService.getUserDocument(userId);
    } else {
      _userInfoFuture = Future.error("로그인된 사용자를 찾을 수 없습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = Provider.of<ThemeProvider>(context).iconColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _userInfoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('사용자 정보를 불러올 수 없습니다.'));
          }

          final userData = snapshot.data!.data()!;
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildInfoTile(
                icon: Icons.badge_outlined,
                title: '이름 (닉네임)',
                subtitle: userData['displayName'] ?? '정보 없음',
                iconColor: iconColor,
              ),
              _buildInfoTile(
                icon: Icons.person_pin_outlined,
                title: '아이디',
                subtitle: userData['userId'] ?? '정보 없음',
                iconColor: iconColor,
              ),
              _buildInfoTile(
                icon: Icons.cake_outlined,
                title: '생년월일',
                subtitle: userData['dateOfBirth'] ?? '정보 없음',
                iconColor: iconColor,
              ),
              _buildInfoTile(
                icon: Icons.email_outlined,
                title: '이메일',
                subtitle: userData['email'] ?? '정보 없음',
                iconColor: iconColor,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}