// lib/presentation/view_models/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  // 실제 앱에 적용된 설정값
  ThemeMode _themeMode = ThemeMode.system;
  double _fontScale = 1.0;

  // 사용자가 '테마 설정' 화면에서 편집 중인 임시 설정값
  ThemeMode _tempThemeMode = ThemeMode.system;
  double _tempFontScale = 1.0;

  // UI에서 값을 읽기 위한 getter
  ThemeMode get themeMode => _themeMode;
  double get fontScale => _fontScale;
  ThemeMode get tempThemeMode => _tempThemeMode; // 편집 화면용
  double get tempFontScale => _tempFontScale; // 편집 화면용

  // ViewModel이 생성될 때 저장된 설정을 불러옵니다.
  ThemeProvider() {
    loadSettings();
  }

  // SharedPreferences에서 저장된 설정 불러오기
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('themeMode');
    if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    // 저장된 글자 크기 불러오기 (없으면 기본값 1.0)
    _fontScale = prefs.getDouble('fontScale') ?? 1.0;
    notifyListeners();
  }

  // '테마 설정' 화면이 열릴 때 호출됨: 실제 값을 임시 값으로 복사
  void beginEdit() {
    _tempThemeMode = _themeMode;
    _tempFontScale = _fontScale;
    notifyListeners();
  }

  // '테마 설정' 화면에서 뒤로가기/취소 시 호출됨: 임시 값을 버림
  void cancelEdit() {
    // 아무것도 하지 않아도 UI가 pop되면서 이 ViewModel의 임시 값은 자연스럽게 사라집니다.
  }

  // '적용' 버튼 클릭 시 호출됨: 임시 값을 실제 값으로 덮어쓰고 영구 저장
  Future<void> saveSettings() async {
    _themeMode = _tempThemeMode;
    _fontScale = _tempFontScale;
    
    final prefs = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.light) {
      await prefs.setString('themeMode', 'light');
    } else if (_themeMode == ThemeMode.dark) {
      await prefs.setString('themeMode', 'dark');
    } else {
      await prefs.remove('themeMode');
    }
    await prefs.setDouble('fontScale', _fontScale);

    notifyListeners(); // 변경된 실제 값을 앱 전체에 알림
  }
  
  // --- '테마 설정' 화면에서 사용할 임시 값 변경 메소드들 ---
  void setTempThemeMode(ThemeMode mode) {
    _tempThemeMode = mode;
    notifyListeners();
  }

  void setTempFontScale(double scale) {
    _tempFontScale = scale;
    notifyListeners();
  }
}