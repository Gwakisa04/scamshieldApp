import 'package:flutter/material.dart';

class AppColors {
  static const brand = Color(0xFF7C1D2E);
  static const brandDark = Color(0xFF4A0E18);
  static const brandDeep = Color(0xFF2B060C);
  static const brandBright = Color(0xFFA62639);
  static const brandSoft = Color(0xFFF9E9EC);
  static const brandPaleText = Color(0xFFF5D5DC);
  static const red = Color(0xFFEF4444);
  static const lightRed = Color(0xFFFEF2F2);
  static const borderRed = Color(0xFFFECACA);
  static const green = Color(0xFF22C55E);
  static const lightGreen = Color(0xFFF0FDF4);
  static const borderGreen = Color(0xFFBBF7D0);
  static const textSlate900 = Color(0xFF0F172A);
  static const textSlate500 = Color(0xFF64748B);
  static const tabInactive = Color(0xFF94A3B8);
  static const bgApp = Color(0xFFF1F5F9);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const divider = Color(0xFFE2E8F0);
  static const messageBoxBg = Color(0xFFF8FAFC);
  static const inputStroke = Color(0xFFE2E8F0);
  static const inputText = Color(0xFF1E293B);
  static const inputHint = Color(0xFF94A3B8);
  static const comfortOrange = Color(0xFFFF8A00);
  static const comfortPeach = Color(0xFFFFF1E0);
  static const comfortBg = Color(0xFFF7F1F2);

  static const darkBg = Color(0xFF140A0D);
  static const darkCard = Color(0xFF21141A);
  static const darkSurface = Color(0xFF2B1A21);
  static const darkDivider = Color(0xFF3C2530);
  static const darkText = Color(0xFFF5EDEF);
  static const darkTextSecondary = Color(0xFFB9A6AC);
}

class ThemeController extends ChangeNotifier {
  bool dark;
  String language;

  ThemeController({required this.dark, required this.language});

  void setDark(bool value) {
    dark = value;
    notifyListeners();
  }

  void setLanguage(String code) {
    language = code;
    notifyListeners();
  }
}
