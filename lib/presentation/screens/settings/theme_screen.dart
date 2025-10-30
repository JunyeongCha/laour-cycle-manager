// lib/presentation/screens/settings/theme_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:laour_cycle_manager/presentation/view_models/theme_provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  void initState() {
    super.initState();
    // 화면이 처음 열릴 때, 현재 설정을 임시 설정으로 복사하는 '편집 시작' 로직을 호출합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).beginEdit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // WillPopScope를 사용하여 뒤로가기 버튼을 눌렀을 때 편집 내용을 취소하도록 합니다.
        return PopScope(
          canPop: false, // 시스템 뒤로가기 버튼을 바로 막습니다.
          onPopInvoked: (didPop) {
            if (didPop) return;
            themeProvider.cancelEdit(); // 편집 취소
            Navigator.of(context).pop(); // 화면 닫기
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('테마 설정'),
              // 뒤로가기 버튼에도 취소 로직을 적용합니다.
              leading: BackButton(
                onPressed: () {
                  themeProvider.cancelEdit();
                  Navigator.pop(context);
                },
              ),
              // '적용' 버튼
              actions: [
                TextButton(
                  onPressed: () async {
                    await themeProvider.saveSettings(); // 설정 저장
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('테마가 적용되었습니다.'), backgroundColor: Colors.green));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('적용'),
                )
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 라이트/다크/시스템 모드 선택
                const Text('모드 설정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                RadioListTile<ThemeMode>(
                  title: const Text('라이트 모드'),
                  value: ThemeMode.light,
                  groupValue: themeProvider.tempThemeMode, // 임시 설정값 사용
                  onChanged: (value) => themeProvider.setTempThemeMode(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('다크 모드'),
                  value: ThemeMode.dark,
                  groupValue: themeProvider.tempThemeMode,
                  onChanged: (value) => themeProvider.setTempThemeMode(value!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('시스템 설정'),
                  value: ThemeMode.system,
                  groupValue: themeProvider.tempThemeMode,
                  onChanged: (value) => themeProvider.setTempThemeMode(value!),
                ),
                const Divider(),
                // 글자 크기 조절 슬라이더
                const Text('글자 크기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: themeProvider.tempFontScale,
                        min: 0.8, max: 1.5, divisions: 7,
                        label: '${(themeProvider.tempFontScale * 100).round()}%',
                        onChanged: themeProvider.setTempFontScale,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('가', style: TextStyle(fontSize: 14 * themeProvider.tempFontScale)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}