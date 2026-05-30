/// ProgressionConfig — semua aturan unlock & XP dikumpulkan di sini.
///
/// Kalau mau ubah jumlah level, XP reward, atau aturan unlock,
/// cukup edit file ini. Tidak perlu ubah kode logic di service.
library;

class ProgressionConfig {
  ProgressionConfig._();

  // ── Level range per difficulty ────────────────────────────
  /// Level ID 1–5: Pemula
  static const int pemulaStart = 1;
  static const int pemulaEnd   = 5;

  /// Level ID 6–13: Menengah
  static const int menengahStart = 6;
  static const int menengahEnd   = 13;

  /// Level ID 14–20: Mahir (Grand Master di level 20)
  static const int mahirStart = 14;
  static const int mahirEnd   = 20;

  /// Total level di seluruh game.
  static const int totalLevels = mahirEnd;

  // ── Feature keys (tambah di sini kalau ada fitur baru) ────
  static const String featureQuiz   = 'quiz';
  static const String featureGambar = 'gambar';
  static const String featureEar    = 'ear';   // future

  // ── XP per action ─────────────────────────────────────────
  /// XP dapat diperoleh dari mana saja; semua masuk totalXp global.
  static int xpForCompleting(String featureKey, int levelId) {
    // Base XP makin besar seiring level naik
    final base = 20 + (levelId - 1) * 5;
    // Bonus kecil per fitur (bisa dikustomisasi nanti)
    final bonus = featureKey == featureGambar ? 5 : 0;
    return base + bonus;
  }

  // ── Unlock rule ───────────────────────────────────────────
  /// Setelah level [currentLevelId] selesai, level berapa yang dibuka?
  /// Return null kalau sudah di level maksimum.
  static int? nextLevelToUnlock(int currentLevelId) {
    if (currentLevelId >= totalLevels) return null;
    return currentLevelId + 1;
  }

  // ── Difficulty helper ─────────────────────────────────────
  static String difficultyOf(int levelId) {
    if (levelId <= pemulaEnd)   return 'Pemula';
    if (levelId <= menengahEnd) return 'Menengah';
    return 'Mahir';
  }
}