/// UserProgress — satu-satunya sumber kebenaran untuk seluruh progression.
///
/// Semua fitur (Kuis Chord, Gambar Chord, Ear Training, dll) membaca
/// dan menulis ke objek ini melalui [ProgressionService].
library;

class UserProgress {
  /// Level terakhir yang di-unlock (global, berlaku untuk SEMUA fitur).
  /// Default: 1 (hanya Pemula Level 1 yang terbuka di awal).
  final int unlockedUpToLevel;

  /// Set level yang sudah diselesaikan, format: "featureKey_levelId"
  /// Contoh: {"quiz_1", "quiz_2", "gambar_1"}
  final Set<String> completedLevels;

  /// Total XP global user (dikumpulkan dari semua fitur).
  final int totalXp;

  /// Timestamp terakhir aktivitas (untuk streak & recent activity).
  final DateTime? lastActivityAt;

  /// Riwayat aktivitas terakhir (max 10 entri, FIFO).
  final List<ActivityEntry> recentActivities;

  const UserProgress({
    this.unlockedUpToLevel = 1,
    this.completedLevels = const {},
    this.totalXp = 0,
    this.lastActivityAt,
    this.recentActivities = const [],
  });

  // ── Computed helpers ────────────────────────────────────────

  /// Apakah level [levelId] sudah di-unlock?
  /// Level di-unlock jika levelId <= unlockedUpToLevel.
  bool isLevelUnlocked(int levelId) => levelId <= unlockedUpToLevel;

  /// Apakah level [levelId] pada fitur [featureKey] sudah selesai?
  bool isLevelCompleted(String featureKey, int levelId) =>
      completedLevels.contains('${featureKey}_$levelId');

  /// Status card level: locked / unlocked / completed.
  LevelStatus levelStatus(String featureKey, int levelId) {
    if (isLevelCompleted(featureKey, levelId)) return LevelStatus.completed;
    if (isLevelUnlocked(levelId)) return LevelStatus.unlocked;
    return LevelStatus.locked;
  }

  // ── copyWith ────────────────────────────────────────────────
  UserProgress copyWith({
    int? unlockedUpToLevel,
    Set<String>? completedLevels,
    int? totalXp,
    DateTime? lastActivityAt,
    List<ActivityEntry>? recentActivities,
  }) {
    return UserProgress(
      unlockedUpToLevel: unlockedUpToLevel ?? this.unlockedUpToLevel,
      completedLevels: completedLevels ?? this.completedLevels,
      totalXp: totalXp ?? this.totalXp,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      recentActivities: recentActivities ?? this.recentActivities,
    );
  }

  // ── JSON serialization ──────────────────────────────────────
  Map<String, dynamic> toJson() => {
        'unlockedUpToLevel': unlockedUpToLevel,
        'completedLevels': completedLevels.toList(),
        'totalXp': totalXp,
        'lastActivityAt': lastActivityAt?.toIso8601String(),
        'recentActivities':
            recentActivities.map((a) => a.toJson()).toList(),
      };

  factory UserProgress.fromJson(Map<String, dynamic> json) => UserProgress(
        unlockedUpToLevel: (json['unlockedUpToLevel'] as int?) ?? 1,
        completedLevels: Set<String>.from(
            (json['completedLevels'] as List<dynamic>?) ?? []),
        totalXp: (json['totalXp'] as int?) ?? 0,
        lastActivityAt: json['lastActivityAt'] != null
            ? DateTime.tryParse(json['lastActivityAt'] as String)
            : null,
        recentActivities: ((json['recentActivities'] as List<dynamic>?) ?? [])
            .map((e) => ActivityEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Enums & supporting models ────────────────────────────────

enum LevelStatus { locked, unlocked, completed }

/// Satu entri aktivitas untuk ditampilkan di Recent Activity.
class ActivityEntry {
  final String message;
  final String featureKey;
  final int levelId;
  final DateTime timestamp;
  final int xpEarned;

  const ActivityEntry({
    required this.message,
    required this.featureKey,
    required this.levelId,
    required this.timestamp,
    this.xpEarned = 0,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'featureKey': featureKey,
        'levelId': levelId,
        'timestamp': timestamp.toIso8601String(),
        'xpEarned': xpEarned,
      };

  factory ActivityEntry.fromJson(Map<String, dynamic> json) => ActivityEntry(
        message: json['message'] as String,
        featureKey: json['featureKey'] as String,
        levelId: json['levelId'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        xpEarned: (json['xpEarned'] as int?) ?? 0,
      );
}