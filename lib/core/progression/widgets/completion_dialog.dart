/// CompletionDialog — popup reward setelah level selesai.
///
/// Panggil via [CompletionDialog.show(context, result)].
library;

import 'package:flutter/material.dart';
import '../models/progression_config.dart';
import '../services/progression_service.dart';

class CompletionDialog extends StatelessWidget {
  final int xpGained;
  final int? unlockedNextLevel;
  final bool alreadyCompleted;

  const CompletionDialog({
    super.key,
    required this.xpGained,
    this.unlockedNextLevel,
    this.alreadyCompleted = false,
  });

  static Future<void> show(
    BuildContext context, {
    required int xpGained,
    int? unlockedNextLevel,
    bool alreadyCompleted = false,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => CompletionDialog(
        xpGained: xpGained,
        unlockedNextLevel: unlockedNextLevel,
        alreadyCompleted: alreadyCompleted,
      ),
    );
  }

  static const Color _cyan   = Color(0xFF00E5FF);
  static const Color _purple = Color(0xFFBD00FF);
  static const Color _bg     = Color(0xFF0D1520);

  @override
  Widget build(BuildContext context) {
    final hasUnlock = unlockedNextLevel != null;
    final unlockDiff = hasUnlock
        ? ProgressionConfig.difficultyOf(unlockedNextLevel!)
        : null;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasUnlock
                ? _purple.withValues(alpha: 0.5)
                : _cyan.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (hasUnlock ? _purple : _cyan).withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _cyan.withValues(alpha: 0.12),
                border: Border.all(color: _cyan.withValues(alpha: 0.4), width: 2),
                boxShadow: [
                  BoxShadow(color: _cyan.withValues(alpha: 0.25), blurRadius: 16),
                ],
              ),
              child: const Icon(Icons.emoji_events_rounded,
                  color: _cyan, size: 32),
            ),
            const SizedBox(height: 16),

            // Judul
            Text(
              alreadyCompleted ? 'Sudah Selesai!' : 'Level Selesai!',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),

            // XP
            if (!alreadyCompleted && xpGained > 0) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _cyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: _cyan.withValues(alpha: 0.3), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: _cyan, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+$xpGained XP',
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        color: _cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Total XP global
            ListenableBuilder(
              listenable: ProgressionService.instance,
              builder: (context, _) {
                return Text(
                  'Total XP: ${ProgressionService.instance.totalXp}',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Unlock banner
            if (hasUnlock) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: _purple.withValues(alpha: 0.35), width: 1),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock_open_rounded,
                        color: _purple, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '$unlockDiff Level $unlockedNextLevel terbuka!',
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cyan.withValues(alpha: 0.15),
                  foregroundColor: _cyan,
                  side: BorderSide(color: _cyan.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'LANJUT',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}