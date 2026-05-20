class QuizLevel {
  final int id;
  final String name;
  final String subtitle;
  final List<String> chordNames;
  final String type;
  final int targetPoints;
  final String difficulty; // 'Pemula' | 'Menengah' | 'Mahir'
  final int timeLimitSeconds; // durasi kuis dalam detik

  const QuizLevel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.chordNames,
    required this.type,
    required this.difficulty,
    this.targetPoints = 10,
    this.timeLimitSeconds = 30, // default fallback
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Konvensi nama chord (harus cocok dengan formatChordName() di game page):
//   major  → root saja       (e.g. 'C')
//   minor  → root + 'm'      (e.g. 'Am')
//   lainnya → root + type    (e.g. 'C7', 'Cmaj7', 'Csus4')
// Shape yang ditampilkan selalu shapes[0] (shape pertama) agar konsisten.
//
// Durasi per tingkat kesulitan:
//   Pemula   → 30 detik  (chord sedikit, sederhana)
//   Menengah → 45 detik  (chord lebih banyak, ada kromatik & ekstensi)
//   Mahir    → 60 detik  (chord kompleks, target poin lebih tinggi)
// ─────────────────────────────────────────────────────────────────────────────
final List<QuizLevel> quizLevels = [

  // ════════════════════════════════════════════════════════════
  //  PEMULA  — 30 detik
  // ════════════════════════════════════════════════════════════
  const QuizLevel(
    id: 1,
    name: 'Major Dasar',
    subtitle: 'C · G · D · A · E',
    chordNames: ['C', 'G', 'D', 'A', 'E'],
    type: 'major',
    difficulty: 'Pemula',
    targetPoints: 8,
    timeLimitSeconds: 30,
  ),
  const QuizLevel(
    id: 2,
    name: 'Minor Dasar',
    subtitle: 'Am · Em · Dm · Bm',
    chordNames: ['Am', 'Em', 'Dm', 'Bm'],
    type: 'minor',
    difficulty: 'Pemula',
    targetPoints: 8,
    timeLimitSeconds: 30,
  ),
  const QuizLevel(
    id: 3,
    name: 'Major & Minor Mix',
    subtitle: 'C · Am · G · Em · D · Bm · F · Fm',
    chordNames: ['C', 'Am', 'G', 'Em', 'D', 'Bm', 'F', 'Fm'],
    type: 'mixed',
    difficulty: 'Pemula',
    targetPoints: 10,
    timeLimitSeconds: 30,
  ),
  const QuizLevel(
    id: 4,
    name: 'Major Lengkap (Natural)',
    subtitle: 'C · D · E · F · G · A · B',
    chordNames: ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
    type: 'major',
    difficulty: 'Pemula',
    targetPoints: 10,
    timeLimitSeconds: 30,
  ),
  const QuizLevel(
    id: 5,
    name: 'Minor Lengkap (Natural)',
    subtitle: 'Cm · Dm · Em · Fm · Gm · Am · Bm',
    chordNames: ['Cm', 'Dm', 'Em', 'Fm', 'Gm', 'Am', 'Bm'],
    type: 'minor',
    difficulty: 'Pemula',
    targetPoints: 10,
    timeLimitSeconds: 30,
  ),

  // ════════════════════════════════════════════════════════════
  //  MENENGAH  — 45 detik
  // ════════════════════════════════════════════════════════════
  const QuizLevel(
    id: 6,
    name: 'Major Kromatik',
    subtitle: 'C# · D# · F# · G# · A#',
    chordNames: ['C#', 'D#', 'F#', 'G#', 'A#'],
    type: 'major',
    difficulty: 'Menengah',
    targetPoints: 10,
    timeLimitSeconds: 45,
  ),
  const QuizLevel(
    id: 7,
    name: 'Minor Kromatik',
    subtitle: 'C#m · D#m · F#m · G#m · A#m',
    chordNames: ['C#m', 'D#m', 'F#m', 'G#m', 'A#m'],
    type: 'minor',
    difficulty: 'Menengah',
    targetPoints: 10,
    timeLimitSeconds: 45,
  ),
  const QuizLevel(
    id: 8,
    name: 'Dominant 7th (Natural)',
    subtitle: 'C7 · D7 · E7 · F7 · G7 · A7 · B7',
    chordNames: ['C7', 'D7', 'E7', 'F7', 'G7', 'A7', 'B7'],
    type: '7',
    difficulty: 'Menengah',
    targetPoints: 10,
    timeLimitSeconds: 45,
  ),
  const QuizLevel(
    id: 9,
    name: 'Dominant 7th (Kromatik)',
    subtitle: 'C#7 · D#7 · F#7 · G#7 · A#7',
    chordNames: ['C#7', 'D#7', 'F#7', 'G#7', 'A#7'],
    type: '7',
    difficulty: 'Menengah',
    targetPoints: 10,
    timeLimitSeconds: 45,
  ),
  const QuizLevel(
    id: 10,
    name: 'Sus4 (Natural)',
    subtitle: 'Csus4 · Dsus4 · Esus4 · Fsus4 · Gsus4 · Asus4 · Bsus4',
    chordNames: ['Csus4', 'Dsus4', 'Esus4', 'Fsus4', 'Gsus4', 'Asus4', 'Bsus4'],
    type: 'sus4',
    difficulty: 'Menengah',
    targetPoints: 10,
    timeLimitSeconds: 45,
  ),
  const QuizLevel(
    id: 11,
    name: 'Sus4 (Kromatik)',
    subtitle: 'C#sus4 · D#sus4 · F#sus4 · G#sus4 · A#sus4',
    chordNames: ['C#sus4', 'D#sus4', 'F#sus4', 'G#sus4', 'A#sus4'],
    type: 'sus4',
    difficulty: 'Menengah',
    targetPoints: 10,
    timeLimitSeconds: 45,
  ),
  const QuizLevel(
    id: 12,
    name: 'Add9 (Natural)',
    subtitle: 'Cadd9 · Dadd9 · Eadd9 · Fadd9 · Gadd9 · Aadd9 · Badd9',
    chordNames: ['Cadd9', 'Dadd9', 'Eadd9', 'Fadd9', 'Gadd9', 'Aadd9', 'Badd9'],
    type: 'add9',
    difficulty: 'Menengah',
    targetPoints: 10,
    timeLimitSeconds: 45,
  ),
  const QuizLevel(
    id: 13,
    name: 'Add9 (Kromatik)',
    subtitle: 'C#add9 · D#add9 · F#add9 · G#add9 · A#add9',
    chordNames: ['C#add9', 'D#add9', 'F#add9', 'G#add9', 'A#add9'],
    type: 'add9',
    difficulty: 'Menengah',
    targetPoints: 10,
    timeLimitSeconds: 45,
  ),

  // ════════════════════════════════════════════════════════════
  //  MAHIR  — 60 detik
  // ════════════════════════════════════════════════════════════
  const QuizLevel(
    id: 14,
    name: 'Major 7th (Natural)',
    subtitle: 'Cmaj7 · Dmaj7 · Emaj7 · Fmaj7 · Gmaj7 · Amaj7 · Bmaj7',
    chordNames: ['Cmaj7', 'Dmaj7', 'Emaj7', 'Fmaj7', 'Gmaj7', 'Amaj7', 'Bmaj7'],
    type: 'maj7',
    difficulty: 'Mahir',
    targetPoints: 12,
    timeLimitSeconds: 60,
  ),
  const QuizLevel(
    id: 15,
    name: 'Major 7th (Kromatik)',
    subtitle: 'C#maj7 · D#maj7 · F#maj7 · G#maj7 · A#maj7',
    chordNames: ['C#maj7', 'D#maj7', 'F#maj7', 'G#maj7', 'A#maj7'],
    type: 'maj7',
    difficulty: 'Mahir',
    targetPoints: 12,
    timeLimitSeconds: 60,
  ),
  const QuizLevel(
    id: 16,
    name: 'Minor 7th (Natural)',
    subtitle: 'Cm7 · Dm7 · Em7 · Fm7 · Gm7 · Am7 · Bm7',
    chordNames: ['Cm7', 'Dm7', 'Em7', 'Fm7', 'Gm7', 'Am7', 'Bm7'],
    type: 'm7',
    difficulty: 'Mahir',
    targetPoints: 12,
    timeLimitSeconds: 60,
  ),
  const QuizLevel(
    id: 17,
    name: 'Minor 7th (Kromatik)',
    subtitle: 'C#m7 · D#m7 · F#m7 · G#m7 · A#m7',
    chordNames: ['C#m7', 'D#m7', 'F#m7', 'G#m7', 'A#m7'],
    type: 'm7',
    difficulty: 'Mahir',
    targetPoints: 12,
    timeLimitSeconds: 60,
  ),
  const QuizLevel(
    id: 18,
    name: 'Power Chord (Natural)',
    subtitle: 'C5 · D5 · E5 · F5 · G5 · A5 · B5',
    chordNames: ['C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'B5'],
    type: '5',
    difficulty: 'Mahir',
    targetPoints: 12,
    timeLimitSeconds: 60,
  ),
  const QuizLevel(
    id: 19,
    name: 'Power Chord (Kromatik)',
    subtitle: 'C#5 · D#5 · F#5 · G#5 · A#5',
    chordNames: ['C#5', 'D#5', 'F#5', 'G#5', 'A#5'],
    type: '5',
    difficulty: 'Mahir',
    targetPoints: 12,
    timeLimitSeconds: 60,
  ),
  const QuizLevel(
    id: 20,
    name: 'Grand Master',
    subtitle: 'Semua jenis chord — 96 chord total',
    chordNames: [
      // Major natural + kromatis
      'C', 'D', 'E', 'F', 'G', 'A', 'B',
      'C#', 'D#', 'F#', 'G#', 'A#',
      // Minor natural + kromatis
      'Cm', 'Dm', 'Em', 'Fm', 'Gm', 'Am', 'Bm',
      'C#m', 'D#m', 'F#m', 'G#m', 'A#m',
      // 7th
      'C7', 'G7', 'D7', 'A7', 'E7', 'B7',
      'C#7', 'F#7', 'G#7',
      // maj7
      'Cmaj7', 'Gmaj7', 'Dmaj7', 'Amaj7', 'Emaj7', 'Fmaj7',
      // m7
      'Cm7', 'Gm7', 'Dm7', 'Am7', 'Em7', 'Fm7',
      // sus4
      'Csus4', 'Gsus4', 'Dsus4', 'Asus4',
      // add9
      'Cadd9', 'Gadd9', 'Dadd9', 'Aadd9',
      // power
      'C5', 'G5', 'D5', 'A5', 'E5', 'F5',
    ],
    type: 'mixed',
    difficulty: 'Mahir',
    targetPoints: 20,
    timeLimitSeconds: 90,
  ),
];
