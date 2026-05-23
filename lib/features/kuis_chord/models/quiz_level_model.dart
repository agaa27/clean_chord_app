class QuizLevel {
  final int id;
  final String name;
  final String subtitle;
  final List<String> chordNames;
  final String type;
  final int targetPoints;
  final String difficulty;
  final int timeLimitSeconds;

  const QuizLevel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.chordNames,
    required this.type,
    required this.difficulty,
    this.targetPoints = 10,
    this.timeLimitSeconds = 30,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Durasi per tingkat kesulitan:
//   Pemula   → 30 detik
//   Menengah → 45 detik
//   Mahir    → 60 detik
//   Grand Master → 90 detik
// ─────────────────────────────────────────────────────────────────────────────
final List<QuizLevel> quizLevels = [

  // ══════════════════════════════════════════════════════════════
  //  PEMULA  — 30 detik
  // ══════════════════════════════════════════════════════════════
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

  // ══════════════════════════════════════════════════════════════
  //  MENENGAH  — 45 detik
  // ══════════════════════════════════════════════════════════════
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

  // ══════════════════════════════════════════════════════════════
  //  MAHIR  — 60 detik
  // ══════════════════════════════════════════════════════════════
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

  // ══════════════════════════════════════════════════════════════
  //  GRAND MASTER — 96 chord, semua dari level 1-19 ✓
  //  FIX: sebelumnya hanya 59 chord (37 hilang) + subtitle salah "96 total"
  // ══════════════════════════════════════════════════════════════
  const QuizLevel(
    id: 20,
    name: 'Grand Master',
    subtitle: 'Semua jenis chord — 96 chord total',
    chordNames: [
      // Major natural (7)
      'C', 'D', 'E', 'F', 'G', 'A', 'B',
      // Major kromatik (5)
      'C#', 'D#', 'F#', 'G#', 'A#',
      // Minor natural (7)
      'Cm', 'Dm', 'Em', 'Fm', 'Gm', 'Am', 'Bm',
      // Minor kromatik (5)
      'C#m', 'D#m', 'F#m', 'G#m', 'A#m',
      // Dominant 7th natural (7)
      'C7', 'D7', 'E7', 'F7', 'G7', 'A7', 'B7',
      // Dominant 7th kromatik (5)
      'C#7', 'D#7', 'F#7', 'G#7', 'A#7',
      // Major 7th natural (7)
      'Cmaj7', 'Dmaj7', 'Emaj7', 'Fmaj7', 'Gmaj7', 'Amaj7', 'Bmaj7',
      // Major 7th kromatik (5)
      'C#maj7', 'D#maj7', 'F#maj7', 'G#maj7', 'A#maj7',
      // Minor 7th natural (7)
      'Cm7', 'Dm7', 'Em7', 'Fm7', 'Gm7', 'Am7', 'Bm7',
      // Minor 7th kromatik (5)
      'C#m7', 'D#m7', 'F#m7', 'G#m7', 'A#m7',
      // Sus4 natural (7)
      'Csus4', 'Dsus4', 'Esus4', 'Fsus4', 'Gsus4', 'Asus4', 'Bsus4',
      // Sus4 kromatik (5)
      'C#sus4', 'D#sus4', 'F#sus4', 'G#sus4', 'A#sus4',
      // Add9 natural (7)
      'Cadd9', 'Dadd9', 'Eadd9', 'Fadd9', 'Gadd9', 'Aadd9', 'Badd9',
      // Add9 kromatik (5)
      'C#add9', 'D#add9', 'F#add9', 'G#add9', 'A#add9',
      // Power chord natural (7)
      'C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'B5',
      // Power chord kromatik (5)
      'C#5', 'D#5', 'F#5', 'G#5', 'A#5',
    ],
    type: 'mixed',
    difficulty: 'Mahir',
    targetPoints: 20,
    timeLimitSeconds: 90,
  ),
];
