import 'package:flutter/material.dart';
import '../../../core/progression/progression.dart';
import '../models/gambar_level_model.dart';
import 'gambar_chord_game_page.dart';

class GambarChordPage extends StatelessWidget {
  const GambarChordPage({super.key});

  static const Color _bg     = Color(0xFF070A0F);
  static const Color _cyan   = Color(0xFF00E5FF);
  static const Color _purple = Color(0xFFBD00FF);
  static const Color _orange = Color(0xFFFFAA00);

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Pemula':   return _cyan;
      case 'Menengah': return _purple;
      case 'Mahir':    return _orange;
      default:         return _cyan;
    }
  }

  IconData _difficultyIcon(String d) {
    switch (d) {
      case 'Pemula':   return Icons.star_outline_rounded;
      case 'Menengah': return Icons.star_half_rounded;
      case 'Mahir':    return Icons.star_rounded;
      default:         return Icons.star_outline_rounded;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Row(
        children: [
          Icon(Icons.fingerprint_rounded, color: Color(0xFF00FF9F), size: 20),
          SizedBox(width: 8),
          Text(
            'Gambar Chord',
            style: TextStyle(
              color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.w600, letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = {
      'Pemula':   gambarLevels.where((l) => l.difficulty == 'Pemula').toList(),
      'Menengah': gambarLevels.where((l) => l.difficulty == 'Menengah').toList(),
      'Mahir':    gambarLevels.where((l) => l.difficulty == 'Mahir').toList(),
    };

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: ListenableBuilder(
        listenable: ProgressionService.instance,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              // Header info
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _cyan.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _cyan.withValues(alpha: 0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _cyan.withValues(alpha: 0.1),
                        border: Border.all(color: _cyan.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(Icons.draw_rounded, color: _cyan, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gambar Posisi Chord!',
                            style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tempatkan jari di fretboard sesuai soal',
                            style: TextStyle(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Grouped levels
              ...grouped.entries.map((entry) {
                final difficulty = entry.key;
                final levels     = entry.value;
                final color      = _difficultyColor(difficulty);
                final icon       = _difficultyIcon(difficulty);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 4),
                      child: Row(
                        children: [
                          Icon(icon, color: color, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            difficulty.toUpperCase(),
                            style: TextStyle(
                              color: color, fontSize: 11,
                              fontWeight: FontWeight.w800, letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Container(height: 1, color: color.withValues(alpha: 0.15))),
                        ],
                      ),
                    ),
                    ...levels.map((level) {
                      final status = ProgressionService.instance.levelStatus(
                        ProgressionConfig.featureGambar, level.id,
                      );
                      return _LevelCard(
                        level: level,
                        accentColor: color,
                        status: status,
                      );
                    }),
                    const SizedBox(height: 12),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GambarLevel level;
  final Color accentColor;
  final LevelStatus status;

  const _LevelCard({
    required this.level,
    required this.accentColor,
    required this.status,
  });

  static const Color _card = Color(0xFF0D1520);

  @override
  Widget build(BuildContext context) {
    final isLocked    = status == LevelStatus.locked;
    final isCompleted = status == LevelStatus.completed;
    final cardColor   = isLocked ? accentColor.withValues(alpha: 0.04) : _card;
    final borderColor = isLocked
        ? Colors.white12
        : isCompleted
            ? accentColor.withValues(alpha: 0.35)
            : accentColor.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: isLocked ? 0.45 : 1.0,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: isLocked
                ? () => _showLockedSnackbar(context)
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GambarChordGamePage(level: level),
                      ),
                    ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Row(
                children: [
                  // Level number / lock icon
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isLocked
                          ? Colors.white.withValues(alpha: 0.04)
                          : accentColor.withValues(alpha: 0.08),
                      border: Border.all(
                        color: isLocked
                            ? Colors.white24
                            : accentColor.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: isLocked
                          ? const Icon(Icons.lock_rounded, color: Colors.white30, size: 16)
                          : Text(
                              '${level.id}',
                              style: TextStyle(
                                color: accentColor, fontSize: 14, fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          level.name,
                          style: TextStyle(
                            color: isLocked ? Colors.white38 : Colors.white,
                            fontSize: 14, fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isLocked ? 'Selesaikan level sebelumnya untuk membuka' : level.subtitle,
                          style: const TextStyle(color: Colors.white38, fontSize: 11),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Trailing: target + status icon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${level.targetPoints} soal',
                        style: TextStyle(
                          color: isLocked ? Colors.white24 : accentColor,
                          fontSize: 12, fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text('target', style: TextStyle(color: Colors.white24, fontSize: 10)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isLocked
                        ? Icons.lock_rounded
                        : isCompleted
                            ? Icons.check_circle_rounded
                            : Icons.chevron_right_rounded,
                    color: isLocked
                        ? Colors.white12
                        : isCompleted
                            ? accentColor
                            : Colors.white24,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLockedSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Colors.white70, size: 16),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Selesaikan level sebelumnya terlebih dahulu!',
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
