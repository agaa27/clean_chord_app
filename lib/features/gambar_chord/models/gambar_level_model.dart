// Model level untuk fitur Gambar Chord
// Struktur sama dengan QuizLevel agar selection page konsisten

class GambarLevel {
  final int id;
  final String name;
  final String subtitle;
  final List<String> chordNames;
  final String type;
  final int targetPoints;
  final String difficulty;

  const GambarLevel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.chordNames,
    required this.type,
    required this.difficulty,
    this.targetPoints = 5,
  });
}

// FIX #8: Durasi dibalik — Pemula lebih banyak waktu (masih belajar),
// Mahir lebih sedikit (sudah hafal, jadi lebih menantang).
int gambarDurationForDifficulty(String difficulty) {
  switch (difficulty) {
    case 'Pemula':   return 40;
    case 'Menengah': return 50;
    case 'Mahir':    return 70;
    default:         return 40;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Konvensi nama sama dengan kuis_chord:
//   major  → root        (e.g. 'C')
//   minor  → root + 'm'  (e.g. 'Am')
//   lainnya → root+type  (e.g. 'C7', 'Cmaj7')
// ─────────────────────────────────────────────────────────────────────────────
final List<GambarLevel> gambarLevels = [

  // ════════════════════════════════════════════════════════════
  //  PEMULA
  // ════════════════════════════════════════════════════════════
  const GambarLevel(
    id: 1,
    name: 'Major Dasar',
    subtitle: 'C · G · D · A · E',
    chordNames: ['C', 'G', 'D', 'A', 'E'],
    type: 'major',
    difficulty: 'Pemula',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 2,
    name: 'Minor Dasar',
    subtitle: 'Am · Em · Dm · Bm',
    chordNames: ['Am', 'Em', 'Dm', 'Bm'],
    type: 'minor',
    difficulty: 'Pemula',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 3,
    name: 'Major & Minor Mix',
    subtitle: 'C · Am · G · Em · D · Bm · F · Fm',
    chordNames: ['C', 'Am', 'G', 'Em', 'D', 'Bm', 'F', 'Fm'],
    type: 'mixed',
    difficulty: 'Pemula',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 4,
    name: 'Major Lengkap (Natural)',
    subtitle: 'C · D · E · F · G · A · B',
    chordNames: ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
    type: 'major',
    difficulty: 'Pemula',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 5,
    name: 'Minor Lengkap (Natural)',
    subtitle: 'Cm · Dm · Em · Fm · Gm · Am · Bm',
    chordNames: ['Cm', 'Dm', 'Em', 'Fm', 'Gm', 'Am', 'Bm'],
    type: 'minor',
    difficulty: 'Pemula',
    targetPoints: 5,
  ),

  // ════════════════════════════════════════════════════════════
  //  MENENGAH
  // ════════════════════════════════════════════════════════════
  const GambarLevel(
    id: 6,
    name: 'Major Kromatik',
    subtitle: 'C# · D# · F# · G# · A#',
    chordNames: ['C#', 'D#', 'F#', 'G#', 'A#'],
    type: 'major',
    difficulty: 'Menengah',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 7,
    name: 'Minor Kromatik',
    subtitle: 'C#m · D#m · F#m · G#m · A#m',
    chordNames: ['C#m', 'D#m', 'F#m', 'G#m', 'A#m'],
    type: 'minor',
    difficulty: 'Menengah',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 8,
    name: 'Dominant 7th (Natural)',
    subtitle: 'C7 · D7 · E7 · F7 · G7 · A7 · B7',
    chordNames: ['C7', 'D7', 'E7', 'F7', 'G7', 'A7', 'B7'],
    type: '7',
    difficulty: 'Menengah',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 9,
    name: 'Dominant 7th (Kromatik)',
    subtitle: 'C#7 · D#7 · F#7 · G#7 · A#7',
    chordNames: ['C#7', 'D#7', 'F#7', 'G#7', 'A#7'],
    type: '7',
    difficulty: 'Menengah',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 10,
    name: 'Sus4 (Natural)',
    subtitle: 'Csus4 · Dsus4 · Esus4 · Fsus4 · Gsus4 · Asus4 · Bsus4',
    chordNames: ['Csus4', 'Dsus4', 'Esus4', 'Fsus4', 'Gsus4', 'Asus4', 'Bsus4'],
    type: 'sus4',
    difficulty: 'Menengah',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 11,
    name: 'Sus4 (Kromatik)',
    subtitle: 'C#sus4 · D#sus4 · F#sus4 · G#sus4 · A#sus4',
    chordNames: ['C#sus4', 'D#sus4', 'F#sus4', 'G#sus4', 'A#sus4'],
    type: 'sus4',
    difficulty: 'Menengah',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 12,
    name: 'Add9 (Natural)',
    subtitle: 'Cadd9 · Dadd9 · Eadd9 · Fadd9 · Gadd9 · Aadd9 · Badd9',
    chordNames: ['Cadd9', 'Dadd9', 'Eadd9', 'Fadd9', 'Gadd9', 'Aadd9', 'Badd9'],
    type: 'add9',
    difficulty: 'Menengah',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 13,
    name: 'Add9 (Kromatik)',
    subtitle: 'C#add9 · D#add9 · F#add9 · G#add9 · A#add9',
    chordNames: ['C#add9', 'D#add9', 'F#add9', 'G#add9', 'A#add9'],
    type: 'add9',
    difficulty: 'Menengah',
    targetPoints: 5,
  ),

  // ════════════════════════════════════════════════════════════
  //  MAHIR
  // ════════════════════════════════════════════════════════════
  const GambarLevel(
    id: 14,
    name: 'Major 7th (Natural)',
    subtitle: 'Cmaj7 · Dmaj7 · Emaj7 · Fmaj7 · Gmaj7 · Amaj7 · Bmaj7',
    chordNames: ['Cmaj7', 'Dmaj7', 'Emaj7', 'Fmaj7', 'Gmaj7', 'Amaj7', 'Bmaj7'],
    type: 'maj7',
    difficulty: 'Mahir',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 15,
    name: 'Major 7th (Kromatik)',
    subtitle: 'C#maj7 · D#maj7 · F#maj7 · G#maj7 · A#maj7',
    chordNames: ['C#maj7', 'D#maj7', 'F#maj7', 'G#maj7', 'A#maj7'],
    type: 'maj7',
    difficulty: 'Mahir',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 16,
    name: 'Minor 7th (Natural)',
    subtitle: 'Cm7 · Dm7 · Em7 · Fm7 · Gm7 · Am7 · Bm7',
    chordNames: ['Cm7', 'Dm7', 'Em7', 'Fm7', 'Gm7', 'Am7', 'Bm7'],
    type: 'm7',
    difficulty: 'Mahir',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 17,
    name: 'Minor 7th (Kromatik)',
    subtitle: 'C#m7 · D#m7 · F#m7 · G#m7 · A#m7',
    chordNames: ['C#m7', 'D#m7', 'F#m7', 'G#m7', 'A#m7'],
    type: 'm7',
    difficulty: 'Mahir',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 18,
    name: 'Power Chord (Natural)',
    subtitle: 'C5 · D5 · E5 · F5 · G5 · A5 · B5',
    chordNames: ['C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'B5'],
    type: '5',
    difficulty: 'Mahir',
    targetPoints: 5,
  ),
  const GambarLevel(
    id: 19,
    name: 'Power Chord (Kromatik)',
    subtitle: 'C#5 · D#5 · F#5 · G#5 · A#5',
    chordNames: ['C#5', 'D#5', 'F#5', 'G#5', 'A#5'],
    type: '5',
    difficulty: 'Mahir',
    targetPoints: 5,
  ),
  // FIX #14: Grand Master kini benar-benar menyertakan SEMUA chord dari semua level.
  const GambarLevel(
    id: 20,
    name: 'Grand Master',
    subtitle: 'Semua jenis chord',
    chordNames: [
      // Major natural
      'C','D','E','F','G','A','B',
      // Major chromatic
      'C#','D#','F#','G#','A#',
      // Minor natural
      'Cm','Dm','Em','Fm','Gm','Am','Bm',
      // Minor chromatic
      'C#m','D#m','F#m','G#m','A#m',
      // Dominant 7 natural
      'C7','D7','E7','F7','G7','A7','B7',
      // Dominant 7 chromatic
      'C#7','D#7','F#7','G#7','A#7',
      // Major 7 natural
      'Cmaj7','Dmaj7','Emaj7','Fmaj7','Gmaj7','Amaj7','Bmaj7',
      // Major 7 chromatic  ← FIX: sebelumnya hilang dari Grand Master
      'C#maj7','D#maj7','F#maj7','G#maj7','A#maj7',
      // Minor 7 natural
      'Cm7','Dm7','Em7','Fm7','Gm7','Am7','Bm7',
      // Minor 7 chromatic  ← FIX: sebelumnya hilang dari Grand Master
      'C#m7','D#m7','F#m7','G#m7','A#m7',
      // Sus4 natural
      'Csus4','Dsus4','Esus4','Fsus4','Gsus4','Asus4','Bsus4',
      // Sus4 chromatic (tambahan — konsisten dengan level 11)
      'C#sus4','D#sus4','F#sus4','G#sus4','A#sus4',
      // Add9 natural
      'Cadd9','Dadd9','Eadd9','Fadd9','Gadd9','Aadd9','Badd9',
      // Add9 chromatic (tambahan — konsisten dengan level 13)
      'C#add9','D#add9','F#add9','G#add9','A#add9',
      // Power chord natural
      'C5','D5','E5','F5','G5','A5','B5',
      // Power chord chromatic  ← FIX: sebelumnya hilang dari Grand Master
      'C#5','D#5','F#5','G#5','A#5',
    ],
    type: 'mixed',
    difficulty: 'Mahir',
    targetPoints: 10,  // naik dari 8 → lebih menantang sesuai jumlah chord
  ),
];