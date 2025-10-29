// lib/services/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_firebase_template/services/firestore_service.dart';

class ThemeProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = Colors.blue;
  Color _iconColor = Colors.blue;
  double _fontScaleFactor = 1.0;

  bool _isEditing = false;
  ThemeMode? _tempThemeMode;
  Color? _tempSeedColor;
  Color? _tempIconColor;
  double? _tempFontScaleFactor;

  ThemeMode get themeMode => _isEditing ? (_tempThemeMode ?? _themeMode) : _themeMode;
  Color get seedColor => _isEditing ? (_tempSeedColor ?? _seedColor) : _seedColor;
  Color get iconColor => _isEditing ? (_tempIconColor ?? _iconColor) : _iconColor;
  double get fontScaleFactor => _fontScaleFactor;
  double get tempFontScaleFactor => _isEditing ? (_tempFontScaleFactor ?? _fontScaleFactor) : _fontScaleFactor;

  void toggleThemeMode(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    saveSettings();
    notifyListeners();
  }
  
  void beginEdit() {
    _isEditing = true;
    _tempThemeMode = _themeMode;
    _tempSeedColor = _seedColor;
    _tempIconColor = _iconColor;
    _tempFontScaleFactor = _fontScaleFactor;
    notifyListeners();
  }

  void cancelEdit() {
    _isEditing = false;
    _tempThemeMode = null;
    _tempSeedColor = null;
    _tempIconColor = null;
    _tempFontScaleFactor = null;
    notifyListeners();
  }

  void setTempSeedColor(Color color) {
    if (!_isEditing) return;
    _tempSeedColor = color;
    notifyListeners();
  }

  void setTempIconColor(Color color) {
    if (!_isEditing) return;
    _tempIconColor = color;
    notifyListeners();
  }
  
  void setTempFontScale(double scale) {
    if (!_isEditing) return;
    _tempFontScaleFactor = scale;
    notifyListeners();
  }

  Future<bool> saveSettings() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return false;

    if (_isEditing) {
      _themeMode = _tempThemeMode ?? _themeMode;
      _seedColor = _tempSeedColor ?? _seedColor;
      _iconColor = _tempIconColor ?? _iconColor;
      _fontScaleFactor = _tempFontScaleFactor ?? _fontScaleFactor;
    }

    final settingsData = {
      'themeMode': _themeMode.name,
      'seedColor': _seedColor.value,
      'iconColor': _iconColor.value,
      'fontScaleFactor': _fontScaleFactor,
    };

    try {
      await _firestoreService.saveUserSettings(userId, settingsData);
      _isEditing = false;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> loadSettings() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _resetToDefaults();
      notifyListeners();
      return;
    }
    
    try {
      final doc = await _firestoreService.getUserDocument(userId);
      if (doc.exists && doc.data()!.containsKey('settings')) {
        final settings = doc.data()!['settings'];
        _themeMode = ThemeMode.values.firstWhere((e) => e.name == settings['themeMode'], orElse: () => ThemeMode.system);
        _seedColor = Color(settings['seedColor'] ?? Colors.blue.value);
        _iconColor = Color(settings['iconColor'] ?? Colors.blue.value);
        _fontScaleFactor = settings['fontScaleFactor'] ?? 1.0;
      } else {
        _resetToDefaults();
      }
    } catch (e) {
      _resetToDefaults();
    }
    notifyListeners();
  }

  void _resetToDefaults() {
    _themeMode = ThemeMode.system;
    _seedColor = Colors.blue;
    _iconColor = Colors.blue;
    _fontScaleFactor = 1.0;
  }
}