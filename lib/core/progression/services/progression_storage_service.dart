library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_progress.dart';

class ProgressionStorageService {
  ProgressionStorageService._();
  static final ProgressionStorageService instance = ProgressionStorageService._();

  static const String _key = 'fretora_user_progress';

  Future<UserProgress> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString(_key);
      if (raw == null) return const UserProgress();
      return UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserProgress();
    }
  }

  Future<void> save(UserProgress p) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(p.toJson()));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}