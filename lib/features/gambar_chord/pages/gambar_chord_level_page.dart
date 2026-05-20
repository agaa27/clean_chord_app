import 'package:flutter/material.dart';
import '../models/gambar_chord_level_model.dart';
import 'gambar_chord_game_page.dart';

class GambarChordLevelPage extends StatelessWidget {
  const GambarChordLevelPage({super.key});

  // Palette (Sama)
  static const Color _bg = Color(0xFF070A0F);
  static const Color _card = Color(0xFF0D1520);
  static const Color _cyan = Color(0xFF00E5FF);
  static const Color _purple = Color(0xFFBD00FF);
  static const Color _orange = Color(0xFFFFAA00);

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Pemula': return _cyan;
      case 'Menengah': return _purple;
      case 'Mahir': return _orange;
      default: return _cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Grouping levels (Sama logicnya)
    final Map<String, List<GambarChordLevel>> grouped = {
      'Pemula': gambarChordLevels.where((l) => l.difficulty == 'Pemula').toList(),
      'Menengah': gambarChordLevels.where((l) => l.difficulty == 'Menengah').toList(),
      'Mahir': gambarChordLevels.where((l) => l.difficulty == 'Mahir').toList(),
    };

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 18), onPressed: () => Navigator.pop(context)),
        title: const Text('Mode: Gambar Chord', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          // Header Info (Desain sama, teks beda)
          Container(
            margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _purple.withOpacity(0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: _purple.withOpacity(0.15))),
            child: Row(children: [
              Icon(Icons.edit_location_alt_rounded, color: _purple, size: 30),
              const SizedBox(width: 15),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Uji Memorimu!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Letakkan titik not sesuai nama chord', style: TextStyle(color: Colors.white38, fontSize: 11)),
              ])),
            ]),
          ),

          // Grouped Levels (Sama persis desainnya)
          ...grouped.entries.map((entry) {
            final difficulty = entry.key;
            final levels = entry.value;
            final color = _difficultyColor(difficulty);

            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Label Kesulitan
              Padding(padding: const EdgeInsets.only(bottom: 10, top: 10), child: Row(children: [
                Text(difficulty.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 2)),
                const SizedBox(width: 10),
                Expanded(child: Container(height: 1, color: color.withOpacity(0.1))),
              ])),
              // List Card Level
              ...levels.map((level) => _LevelCard(level: level, accentColor: color)),
              const SizedBox(height: 10),
            ]);
          }),
        ],
      ),
    );
  }
}

// _LevelCard (Sama persis desainnya, navigasi beda)
class _LevelCard extends StatelessWidget {
  final GambarChordLevel level;
  final Color accentColor;
  const _LevelCard({required this.level, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1520), // _card
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => GambarChordGamePage(level: level), // Buka Game Gambar
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            // ID Circle
            Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: accentColor.withOpacity(0.1), border: Border.all(color: accentColor.withOpacity(0.3))),
              child: Center(child: Text('${level.id}', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold)))),
            const SizedBox(width: 14),
            // Nama & Subtitle
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(level.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 2),
              Text(level.subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            // Target Poin
            Text('${level.targetPoints} pts', style: TextStyle(color: accentColor.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
          ]),
        ),
      ),
    );
  }
}