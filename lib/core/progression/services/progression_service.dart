library;

import 'package:flutter/foundation.dart';
import '../models/user_progress.dart';
import '../models/progression_config.dart';
import 'progression_storage_service.dart';

class ProgressionService extends ChangeNotifier {
  ProgressionService._();
  static final ProgressionService instance = ProgressionService._();

  UserProgress _progress = const UserProgress();
  bool _initialized = false;

  UserProgress get progress        => _progress;
  int  get totalXp                 => _progress.totalXp;
  int  get unlockedUpToLevel       => _progress.unlockedUpToLevel;
  bool get initialized             => _initialized;

  // ── Init ────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    _progress = await ProgressionStorageService.instance.load();
    _initialized = true;
    notifyListeners();
  }

  // ── Public helpers ───────────────────────────────────────────
  bool isLevelUnlocked(int levelId) => _progress.isLevelUnlocked(levelId);

  bool isLevelCompleted(String featureKey, int levelId) =>
      _progress.isLevelCompleted(featureKey, levelId);

  LevelStatus levelStatus(String featureKey, int levelId) =>
      _progress.levelStatus(featureKey, levelId);

  // ── completeLevel ────────────────────────────────────────────
  Future<CompletionResult> completeLevel(
    String featureKey,
    int levelId, {
    String? customMessage,
  }) async {
    final alreadyDone = isLevelCompleted(featureKey, levelId);
    final xpGain      = alreadyDone ? 0 : ProgressionConfig.xpForCompleting(featureKey, levelId);
    final nextUnlock  = ProgressionConfig.nextLevelToUnlock(levelId);
    final didUnlockNew = !alreadyDone &&
        nextUnlock != null &&
        nextUnlock > _progress.unlockedUpToLevel;

    if (!alreadyDone) {
      final newCompleted = Set<String>.from(_progress.completedLevels)
        ..add('${featureKey}_$levelId');

      final newUnlockedUpTo = didUnlockNew ? nextUnlock! : _progress.unlockedUpToLevel;

      final activity = ActivityEntry(
        message: customMessage ??
            _defaultMessage(featureKey, levelId, didUnlockNew, nextUnlock),
        featureKey: featureKey,
        levelId: levelId,
        timestamp: DateTime.now(),
        xpEarned: xpGain,
      );

      final newActivities = [activity, ..._progress.recentActivities].take(10).toList();

      _progress = _progress.copyWith(
        completedLevels: newCompleted,
        unlockedUpToLevel: newUnlockedUpTo,
        totalXp: _progress.totalXp + xpGain,
        lastActivityAt: DateTime.now(),
        recentActivities: newActivities,
      );

      await _save();
      notifyListeners();
    }

    return CompletionResult(
      featureKey: featureKey,
      levelId: levelId,
      xpGained: xpGain,
      unlockedNextLevel: didUnlockNew ? nextUnlock : null,
      alreadyCompleted: alreadyDone,
    );
  }

  Future<void> addXp(int amount) async {
    if (amount <= 0) return;
    _progress = _progress.copyWith(totalXp: _progress.totalXp + amount);
    await _save();
    notifyListeners();
  }

  Future<void> unlockNextLevel() async {
    final next = _progress.unlockedUpToLevel + 1;
    if (next > ProgressionConfig.totalLevels) return;
    _progress = _progress.copyWith(unlockedUpToLevel: next);
    await _save();
    notifyListeners();
  }

  Future<void> resetProgress() async {
    _progress = const UserProgress();
    await ProgressionStorageService.instance.reset();
    notifyListeners();
  }

  // ── Private ──────────────────────────────────────────────────
  Future<void> _save() => ProgressionStorageService.instance.save(_progress);

  String _defaultMessage(String featureKey, int levelId, bool didUnlock, int? nextUnlock) {
    final name = _featureName(featureKey);
    if (didUnlock && nextUnlock != null) {
      final nd = ProgressionConfig.difficultyOf(nextUnlock);
      return 'Selesai $name Level $levelId — Unlock $nd Level $nextUnlock!';
    }
    final d = ProgressionConfig.difficultyOf(levelId);
    return 'Selesai $name $d Level $levelId';
  }

  String _featureName(String key) {
    switch (key) {
      case ProgressionConfig.featureQuiz:   return 'Kuis Chord';
      case ProgressionConfig.featureGambar: return 'Gambar Chord';
      case ProgressionConfig.featureEar:    return 'Ear Training';
      default: return key;
    }
  }
}

// ── CompletionResult ─────────────────────────────────────────
class CompletionResult {
  final String featureKey;
  final int    levelId;
  final int    xpGained;
  final int?   unlockedNextLevel;
  final bool   alreadyCompleted;

  const CompletionResult({
    required this.featureKey,
    required this.levelId,
    required this.xpGained,
    this.unlockedNextLevel,
    this.alreadyCompleted = false,
  });

  bool   get hasNewUnlock       => unlockedNextLevel != null;
  String get difficultyUnlocked => hasNewUnlock
      ? ProgressionConfig.difficultyOf(unlockedNextLevel!)
      : '';
}