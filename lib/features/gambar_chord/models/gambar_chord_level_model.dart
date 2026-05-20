class GambarChordLevel {
  final int id;
  final String name;
  final String subtitle;
  final List<String> chordNames;
  final String type;
  final int targetPoints;
  final String difficulty; // 'Pemula' | 'Menengah' | 'Mahir'
  final int timeLimitSeconds;

  const GambarChordLevel({
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

// Data level disamakan dengan Kuis Chord
final List<GambarChordLevel> gambarChordLevels = [
  // PEMULA
  const GambarChordLevel(
    id: 1, name: 'Major Dasar', subtitle: 'C · G · D · A · E',
    chordNames: ['C', 'G', 'D', 'A', 'E'],
    type: 'major', difficulty: 'Pemula', targetPoints: 8, timeLimitSeconds: 30,
  ),
  const GambarChordLevel(
    id: 2, name: 'Minor Dasar', subtitle: 'Am · Em · Dm · Bm',
    chordNames: ['Am', 'Em', 'Dm', 'Bm'],
    type: 'minor', difficulty: 'Pemula', targetPoints: 8, timeLimitSeconds: 30,
  ),
  const GambarChordLevel(
    id: 3, name: 'Major & Minor Mix', subtitle: 'C · Am · G · Em ...',
    chordNames: ['C', 'Am', 'G', 'Em', 'D', 'Bm', 'F', 'Fm'],
    type: 'mixed', difficulty: 'Pemula', targetPoints: 10, timeLimitSeconds: 30,
  ),
  // MENENGAH
  const GambarChordLevel(
    id: 6, name: 'Major Kromatik', subtitle: 'C# · D# · F# · G# · A#',
    chordNames: ['C#', 'D#', 'F#', 'G#', 'A#'],
    type: 'major', difficulty: 'Menengah', targetPoints: 10, timeLimitSeconds: 45,
  ),
  const GambarChordLevel(
    id: 8, name: 'Dominant 7th (Natural)', subtitle: 'C7 · D7 · E7 ...',
    chordNames: ['C7', 'D7', 'E7', 'F7', 'G7', 'A7', 'B7'],
    type: '7', difficulty: 'Menengah', targetPoints: 10, timeLimitSeconds: 45,
  ),
  // MAHIR
  const GambarChordLevel(
    id: 14, name: 'Major 7th (Natural)', subtitle: 'Cmaj7 · Dmaj7 ...',
    chordNames: ['Cmaj7', 'Dmaj7', 'Emaj7', 'Fmaj7', 'Gmaj7', 'Amaj7', 'Bmaj7'],
    type: 'maj7', difficulty: 'Mahir', targetPoints: 12, timeLimitSeconds: 60,
  ),
  const GambarChordLevel(
    id: 20, name: 'Grand Master', subtitle: 'Semua jenis chord',
    chordNames: [
      'C', 'D', 'E', 'F', 'G', 'A', 'B', 'C#', 'F#',
      'Cm', 'Dm', 'Em', 'Am', 'Bm', 'C#m',
      'C7', 'G7', 'D7', 'E7', 'Cmaj7', 'Fmaj7', 'Cm7', 'Am7',
      'Csus4', 'Gsus4', 'Cadd9', 'C5', 'A5',
    ],
    type: 'mixed', difficulty: 'Mahir', targetPoints: 20, timeLimitSeconds: 90,
  ),
];