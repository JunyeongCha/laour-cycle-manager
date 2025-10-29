// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_template/services/theme_provider.dart';
import 'package:flutter_firebase_template/screens/my_page_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iconColor = Provider.of<ThemeProvider>(context).iconColor;

    return Scaffold(
      appBar: AppBar(
        // leading을 null로 설정하여 뒤로가기 버튼 자동 생성을 막습니다.
        automaticallyImplyLeading: false,
        title: const Text('My App'),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyPageScreen()),
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          '환영합니다!\n이곳에서부터 새로운 앱을 만들어보세요.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}