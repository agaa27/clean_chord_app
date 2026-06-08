/// LevelCardWidget — reusable card untuk semua fitur.
///
/// Otomatis menampilkan state: locked / unlocked / completed
/// berdasarkan data dari [ProgressionService].
///
/// Gunakan di KuisChordPage, GambarChordPage, EarTrainingPage, dll.
/// Tidak perlu tulis ulang logic lock/unlock di setiap halaman.
///
/// Contoh:
///   LevelCardWidget(
///     featureKey: ProgressionConfig.featureQuiz,
///     levelId: level.id,
///     title: level.name,
///     subtitle: level.subtitle,
///     meta: '${level.targetPoints} pts',
///     accentColor: _cyan,
///     onTap: () => Navigator.push(...),
///   )
library;

import 'package:flutter/material.dart';
import '../models/user_progress.dart';
import '../services/progression_service.dart';

class LevelCardWidget extends StatelessWidget {
  final String featureKey;
  final int levelId;
  final String title;
  final String subtitle;
  final String meta;
  final Color accentColor;

  /// Callback ketika card di-tap (hanya aktif jika unlocked/completed).
  final VoidCallback? onTap;

  const LevelCardWidget({
    super.key,
    required this.featureKey,
    required this.levelId,
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.accentColor,
    this.onTap,
  });

  static const Color _cardBg = Color(0xFF0D1520);

  @override
  Widget build(BuildContext context) {
    // ListenableBuilder → rebuild otomatis kalau progress berubah
    return ListenableBuilder(
      listenable: ProgressionService.instance,
      builder: (context, _) {
        final status = ProgressionService.instance.levelStatus(
          featureKey,
          levelId,
        );
        return _buildCard(context, status);
      },
    );
  }

  Widget _buildCard(BuildContext context, LevelStatus status) {
    final isLocked = status == LevelStatus.locked;
    final isCompleted = status == LevelStatus.completed;

    // Warna & opacity berdasarkan status
    final effectiveColor = isLocked ? Colors.white24 : accentColor;
    final cardOpacity = isLocked ? 0.45 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isLocked ? null : onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isCompleted
                      ? effectiveColor.withValues(alpha: 0.45)
                      : effectiveColor.withValues(alpha: 0.12),
                  width: isCompleted ? 1.4 : 1.0,
                ),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.10),
                          blurRadius: 12,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // ── Level ID circle / icon ──────────────
                  _buildLeadingBadge(isLocked, isCompleted, effectiveColor),
                  const SizedBox(width: 14),

                  // ── Title & subtitle ────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isLocked ? Colors.white38 : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // ── Meta (pts / soal) + trailing icon ───
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        meta,
                        style: TextStyle(
                          color: isLocked ? Colors.white24 : effectiveColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCompleted
                            ? 'selesai'
                            : (isLocked ? 'terkunci' : 'target'),
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  _buildTrailingIcon(isLocked, isCompleted, effectiveColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingBadge(
    bool isLocked,
    bool isCompleted,
    Color effectiveColor,
  ) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: effectiveColor.withValues(alpha: 0.08),
        border: Border.all(
          color: effectiveColor.withValues(alpha: isLocked ? 0.15 : 0.35),
          width: 1.5,
        ),
      ),
      child: Center(
        child: isLocked
            ? const Icon(Icons.lock_rounded, color: Colors.white24, size: 16)
            : isCompleted
            ? Icon(Icons.check_rounded, color: effectiveColor, size: 18)
            : Text(
                '$levelId',
                style: TextStyle(
                  color: effectiveColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildTrailingIcon(
    bool isLocked,
    bool isCompleted,
    Color effectiveColor,
  ) {
    if (isLocked) {
      return const Icon(
        Icons.lock_outline_rounded,
        color: Colors.white12,
        size: 18,
      );
    }
    if (isCompleted) {
      return Icon(Icons.replay_rounded, color: effectiveColor, size: 18);
    }
    return const Icon(
      Icons.chevron_right_rounded,
      color: Colors.white24,
      size: 20,
    );
  }
}
