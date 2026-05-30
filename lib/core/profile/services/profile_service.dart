import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

/// ProfileService — engine profil user offline.
///
/// Singleton + ChangeNotifier, sepenuhnya terpisah dari ProgressionService.
/// Key SharedPreferences berbeda: 'clean_chord_user_profile'
/// sehingga tidak bisa bentrok dengan 'fretora_user_progress'.
class ProfileService extends ChangeNotifier {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  static const String _key = 'clean_chord_user_profile';

  UserProfile? _profile;

  /// Profil aktif. Null kalau belum diisi (user baru).
  UserProfile? get profile => _profile;

  /// True kalau user sudah pernah mengisi profil.
  bool get hasProfile => _profile != null && _profile!.name.trim().isNotEmpty;

  // ── Init — dipanggil sekali di main() ────────────────────────
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw   = prefs.getString(_key);
      if (raw != null) {
        _profile = UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
    } catch (_) {
      _profile = null;
    }
  }

  // ── Save — simpan profil baru atau update ────────────────────
  Future<void> save(UserProfile profile) async {
    _profile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(profile.toJson()));
    notifyListeners();
  }

  // ── Reset — hanya untuk keperluan testing/dev ────────────────
  Future<void> reset() async {
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }
}
