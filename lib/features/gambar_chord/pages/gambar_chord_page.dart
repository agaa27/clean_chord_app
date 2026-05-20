import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final grouped = {
      'Pemula':   gambarLevels.where((l) => l.difficulty == 'Pemula').toList(),
      'Menengah': gambarLevels.where((l) => l.difficulty == 'Menengah').toList(),
      'Mahir':    gambarLevels.where((l) => l.difficulty == 'Mahir').toList(),
    };

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white54, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gambar Chord',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      ),
      body: ListView(
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
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _cyan.withValues(alpha: 0.1),
                    border:
                        Border.all(color: _cyan.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.draw_rounded,
                      color: _cyan, size: 18),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gambar Posisi Chord!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tempatkan jari di fretboard sesuai soal',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
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
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: color.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
                ...levels.map((level) => _LevelCard(
                      level: level,
                      accentColor: color,
                    )),
                const SizedBox(height: 12),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final GambarLevel level;
  final Color accentColor;

  const _LevelCard({required this.level, required this.accentColor});

  static const Color _card = Color(0xFF0D1520);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GambarChordGamePage(level: level),
            ),
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withValues(alpha: 0.08),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${level.id}',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        level.subtitle,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${level.targetPoints} soal',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'target',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white24,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
