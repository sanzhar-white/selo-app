import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:selo/core/theme/theme.dart';
import 'package:selo/core/services/local_storage_service.dart';

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeNotifier() : super(lightTheme) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = LocalStorageService.getTheme();
    if (isDark != null) {
      state = isDark ? darkTheme : lightTheme;
    }
  }

  Future<void> toggleTheme() async {
    final isDark = state == darkTheme;
    state = isDark ? lightTheme : darkTheme;
    await LocalStorageService.saveTheme(!isDark);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeData>(
  (ref) => ThemeNotifier(),
);
