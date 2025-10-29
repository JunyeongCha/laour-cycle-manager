// lib/screens/theme_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_firebase_template/services/theme_provider.dart';

class ThemeScreen extends StatefulWidget {
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  void initState() {
    super.initState();
    // [수정] 로그인 시 해결했던 것과 동일하게, 첫 프레임이 그려진 후 beginEdit()를 호출하도록 수정합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false).beginEdit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return WillPopScope(
          onWillPop: () async {
            themeProvider.cancelEdit();
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text('테마 설정'),
              leading: BackButton(
                onPressed: () {
                  themeProvider.cancelEdit();
                  Navigator.pop(context);
                },
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final success = await themeProvider.saveSettings();
                    if (mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('테마가 적용되었습니다.'), backgroundColor: Colors.green));
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장에 실패했습니다.'), backgroundColor: Colors.red));
                      }
                    }
                  },
                  child: const Text('적용'),
                )
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildColorPicker(
                  title: '테마 색상',
                  currentColor: themeProvider.seedColor,
                  onColorSelected: themeProvider.setTempSeedColor,
                ),
                const Divider(),
                _buildColorPicker(
                  title: '아이콘 색상',
                  currentColor: themeProvider.iconColor,
                  onColorSelected: themeProvider.setTempIconColor,
                ),
                const Divider(),
                const Text('글자 크기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: themeProvider.tempFontScaleFactor,
                        min: 0.8,
                        max: 1.5,
                        divisions: 7,
                        label: '${(themeProvider.tempFontScaleFactor * 100).round()}%',
                        onChanged: themeProvider.setTempFontScale,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '가',
                      style: TextStyle(fontSize: 14 * themeProvider.tempFontScaleFactor),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorPicker({
    required String title,
    required Color currentColor,
    required Function(Color) onColorSelected,
  }) {
    final List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.red, Colors.teal];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Wrap(
              spacing: 10,
              children: colors.map((color) => GestureDetector(
                onTap: () => onColorSelected(color),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: color,
                  child: currentColor.value == color.value ? const Icon(Icons.check, color: Colors.white) : null,
                ),
              )).toList(),
            ),
            CircleAvatar(radius: 18, backgroundColor: currentColor),
          ],
        ),
      ],
    );
  }
}