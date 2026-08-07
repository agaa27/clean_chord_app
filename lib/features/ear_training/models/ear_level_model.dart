import '../../kuis_chord/models/quiz_level_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// earLevels — sengaja dibuat TERPISAH dari quizLevels (bukan pakai list yang
// sama apa adanya), karena Ear Training butuh waktu lebih panjang per level
// (user biasanya perlu replay suara 3-4 kali dulu sebelum bisa nebak, beda
// sama Kuis/Gambar Chord yang tinggal liat diagram sekali lirik). Kalau kita
// ubah timeLimitSeconds langsung di quizLevels, Kuis Chord & Gambar Chord
// ikut kena juga — makanya dibikin list turunan sendiri di sini.
//
// Semua field lain (id, name, subtitle, chordNames, type, difficulty,
// targetPoints) tetap sama persis dengan quizLevels, cuma timeLimitSeconds
// yang di-perpanjang sesuai tingkat kesulitan.
// ─────────────────────────────────────────────────────────────────────────────

int _earTimeLimit(String difficulty) {
  switch (difficulty) {
    case 'Pemula':
      return 50; // sebelumnya 30
    case 'Menengah':
      return 70; // sebelumnya 45
    case 'Mahir':
      return 100; // sebelumnya 60 (atau 90 khusus Grand Master, lihat di bawah)
    default:
      return 60;
  }
}

final List<QuizLevel> earLevels = quizLevels.map((l) {
  // Grand Master (level 20) levelnya udah paling berat (96 chord campur),
  // kasih waktu paling panjang secara khusus.
  final timeLimit = l.id == 20 ? 130 : _earTimeLimit(l.difficulty);
  return QuizLevel(
    id: l.id,
    name: l.name,
    subtitle: l.subtitle,
    chordNames: l.chordNames,
    type: l.type,
    difficulty: l.difficulty,
    targetPoints: l.targetPoints,
    timeLimitSeconds: timeLimit,
  );
}).toList();
