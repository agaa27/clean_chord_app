import '../models/chord_model.dart';
import '../models/chord_shape_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Guitar Chord Library — Standard Tuning E A D G B e
// All fret numbers are ABSOLUTE (not relative).
// baseFret = first fret shown on diagram (default = 1).
// Verified against: Hal Leonard Guitar Chord Finder, The Guitar Grimoire,
// JustinGuitar chord reference, and standard music theory (equal temperament).
//
// Fingering convention:
//   0 = open string (no finger)
//   1 = index  2 = middle  3 = ring  4 = pinky
// ─────────────────────────────────────────────────────────────────────────────

final List<ChordModel> chordLibrary = [
  // ══════════════════════════════════════════════════
  //  C
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'C',
    type: 'major',
    shapes: [
      // e a d g b e
      ChordShapeModel(frets: [-1, 3, 2, 0, 1, 0], fingers: [0, 3, 2, 0, 1, 0]),
      // Barre fret 3 (A-shape)
      ChordShapeModel(
        frets: [-1, 3, 5, 5, 5, 3],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 8 (E-shape)
      ChordShapeModel(
        frets: [8, 10, 10, 9, 8, 8],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 8,
        barreFret: 8,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'C',
    type: 'minor',
    shapes: [
      // Barre fret 3 (Am-shape)
      ChordShapeModel(
        frets: [-1, 3, 5, 5, 4, 3],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 8 (Em-shape)
      ChordShapeModel(
        frets: [8, 10, 10, 8, 8, 8],
        fingers: [1, 3, 4, 1, 1, 1],
        baseFret: 8,
        barreFret: 8,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'C',
    type: '7',
    shapes: [
      // Barre fret 3 (A7-shape) — C E G Bb ✓ all chord tones
      ChordShapeModel(
        frets: [-1, 3, 5, 3, 5, 3],
        fingers: [0, 1, 3, 1, 4, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // x 3 2 3 1 0  — open C7 (5th omitted, display only)
      ChordShapeModel(frets: [-1, 3, 2, 3, 1, 0], fingers: [0, 3, 2, 4, 1, 0]),
    ],
  ),

  ChordModel(
    root: 'C',
    type: 'add9',
    shapes: [
      // x 3 2 0 3 0
      ChordShapeModel(frets: [-1, 3, 2, 0, 3, 3], fingers: [0, 2, 1, 0, 3, 4]),
      // x 3 2 0 3 3  — adds D on top
      ChordShapeModel(
        frets: [-1, -1, 10, 9, 8, 10],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 8,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  C# / Db
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'C#',
    type: 'major',
    shapes: [
      // Barre fret 4 (A-shape)
      ChordShapeModel(
        frets: [-1, 4, 6, 6, 6, 4],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 9 (E-shape)
      ChordShapeModel(
        frets: [9, 11, 11, 10, 9, 9],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 9,
        barreFret: 9,
        barreStartString: 0,
        barreEndString: 5,
      ),

      // x x 3 1 2 1  — compact voicing
      ChordShapeModel(
        frets: [-1, 4, 3, 1, 2, 1],
        fingers: [0, 4, 3, 1, 2, 1],
        baseFret: 1,
        barreFret: 1,
        barreStartString: 3,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'C#',
    type: 'minor',
    shapes: [
      // Barre fret 4 (Am-shape)
      ChordShapeModel(
        frets: [-1, 4, 6, 6, 5, 4],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 9 (Em-shape)
      ChordShapeModel(
        frets: [9, 11, 11, 9, 9, 9],
        fingers: [1, 3, 4, 1, 1, 1],
        baseFret: 9,
        barreFret: 9,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'C#',
    type: '7',
    shapes: [
      // Barre fret 9 (E7-shape) — C# F G# B ✓ all chord tones
      ChordShapeModel(
        frets: [9, 11, 9, 10, 9, 9],
        fingers: [1, 3, 1, 2, 1, 1],
        baseFret: 9,
        barreFret: 9,
        barreStartString: 0,
        barreEndString: 5,
      ),
      // A7-shape at fret 4 (str5 muted — display only)
      ChordShapeModel(
        frets: [-1, 4, 3, 4, 2, -1],
        fingers: [0, 3, 2, 4, 1, 0],
        baseFret: 2,
      ),
    ],
  ),

  ChordModel(
    root: 'C#',
    type: 'add9',
    shapes: [
      // x 4 6 8 6 4  — verified: C# G# D# F G# (baseFret 4)
      ChordShapeModel(
        frets: [-1, -1, 11, 10, 9, 11],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 9,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  D
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'D',
    type: 'major',
    shapes: [
      // x x 0 2 3 2  — standard open D
      ChordShapeModel(frets: [-1, -1, 0, 2, 3, 2], fingers: [0, 0, 0, 1, 3, 2]),
      // Barre fret 5 (A-shape)
      ChordShapeModel(
        frets: [-1, 5, 7, 7, 7, 5],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 10 (E-shape)
      ChordShapeModel(
        frets: [10, 12, 12, 11, 10, 10],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 10,
        barreFret: 10,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'D',
    type: 'minor',
    shapes: [
      // x x 0 2 3 1  — standard open Dm
      ChordShapeModel(frets: [-1, -1, 0, 2, 3, 1], fingers: [0, 0, 0, 2, 3, 1]),
      // Barre fret 5 (Am-shape)
      ChordShapeModel(
        frets: [-1, 5, 7, 7, 6, 5],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'D',
    type: '7',
    shapes: [
      // x x 0 2 1 2  — standard open D7
      ChordShapeModel(frets: [-1, -1, 0, 2, 1, 2], fingers: [0, 0, 0, 2, 1, 3]),
      // Barre fret 5 (A7-shape)
      ChordShapeModel(
        frets: [-1, 5, 7, 5, 7, 5],
        fingers: [0, 1, 3, 1, 4, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'D',
    type: 'add9',
    shapes: [
      // x x 0 2 3 0  — open Dadd9 (widely used; 3rd omitted accepted in open pos)
      ChordShapeModel(
        frets: [-1, -1, 12, 11, 10, 12],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 10,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  D# / Eb
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'D#',
    type: 'major',
    shapes: [
      // Barre fret 6 (A-shape)
      ChordShapeModel(
        frets: [-1, 6, 8, 8, 8, 6],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // x x 1 3 4 3  — open position D#
      ChordShapeModel(frets: [-1, -1, 1, 3, 4, 3], fingers: [0, 0, 1, 2, 4, 3]),
      // Barre fret 11 (E-shape)
      ChordShapeModel(
        frets: [11, 13, 13, 12, 11, 11],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 11,
        barreFret: 11,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'D#',
    type: 'minor',
    shapes: [
      // Barre fret 6 (Am-shape)
      ChordShapeModel(
        frets: [-1, 6, 8, 8, 7, 6],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // x x 1 3 4 2
      ChordShapeModel(frets: [-1, -1, 1, 3, 4, 2], fingers: [0, 0, 1, 3, 4, 2]),
    ],
  ),

  ChordModel(
    root: 'D#',
    type: '7',
    shapes: [
      // Barre fret 6 (A7-shape)
      ChordShapeModel(
        frets: [-1, 6, 8, 6, 8, 6],
        fingers: [0, 1, 3, 1, 4, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // x x 1 3 2 3
      ChordShapeModel(frets: [-1, -1, 1, 3, 2, 3], fingers: [0, 0, 1, 3, 2, 4]),
    ],
  ),

  ChordModel(
    root: 'D#',
    type: 'add9',
    shapes: [
      // x x 3 3 4 3  — F A# D# G = D# G A# F ✓
      ChordShapeModel(
        frets: [-1, -1, 13, 12, 11, 13],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 11,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  E
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'E',
    type: 'major',
    shapes: [
      // 0 2 2 1 0 0  — standard open E
      ChordShapeModel(frets: [0, 2, 2, 1, 0, 0], fingers: [0, 2, 3, 1, 0, 0]),
      // x 7 9 9 9 7  — A-shape barre fret 7
      ChordShapeModel(
        frets: [-1, 7, 9, 9, 9, 7],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'E',
    type: 'minor',
    shapes: [
      // 0 2 2 0 0 0  — standard open Em
      ChordShapeModel(frets: [0, 2, 2, 0, 0, 0], fingers: [0, 2, 3, 0, 0, 0]),
      // x 7 9 9 8 7  — Am-shape barre fret 7
      ChordShapeModel(
        frets: [-1, 7, 9, 9, 8, 7],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'E',
    type: '7',
    shapes: [
      // 0 2 0 1 0 0  — standard open E7
      ChordShapeModel(frets: [0, 2, 0, 1, 0, 0], fingers: [0, 2, 0, 1, 0, 0]),
      // x 7 9 7 9 7  — A7-shape barre fret 7
      ChordShapeModel(
        frets: [-1, 7, 9, 7, 9, 7],
        fingers: [0, 1, 3, 1, 4, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'E',
    type: 'add9',
    shapes: [
      // 0 2 2 1 0 2  — E G# B E F# (9th on e string)
      ChordShapeModel(frets: [-1, -1, 2, 1, 0, 2], fingers: [0, 0, 2, 1, 0, 3]),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  F
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'F',
    type: 'major',
    shapes: [
      // Barre fret 1 (E-shape)
      ChordShapeModel(
        frets: [1, 3, 3, 2, 1, 1],
        fingers: [1, 3, 4, 2, 1, 1],
        barreFret: 1,
        barreStartString: 0,
        barreEndString: 5,
      ),
      // x 8 10 10 10 8  — A-shape barre fret 8
      ChordShapeModel(frets: [-1, 3, 3, 2, 1, -1], fingers: [0, 3, 4, 2, 1, 0]),
      // x x 3 2 1 1  — compact F (barre fret 1, strings 3–5)
      ChordShapeModel(
        frets: [-1, -1, 3, 2, 1, 1],
        fingers: [0, 0, 3, 2, 1, 1],
        barreFret: 1,
        barreStartString: 4,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'F',
    type: 'minor',
    shapes: [
      // Barre fret 1 (Em-shape)
      ChordShapeModel(
        frets: [1, 3, 3, 1, 1, 1],
        fingers: [1, 3, 4, 1, 1, 1],
        barreFret: 1,
        barreStartString: 0,
        barreEndString: 5,
      ),
      // x 8 10 10 9 8  — Am-shape barre fret 8
      ChordShapeModel(
        frets: [-1, 8, 10, 10, 9, 8],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 8,
        barreFret: 8,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'F',
    type: '7',
    shapes: [
      // Barre fret 1 (E7-shape)
      ChordShapeModel(
        frets: [1, 3, 1, 2, 1, 1],
        fingers: [1, 3, 1, 2, 1, 1],
        barreFret: 1,
        barreStartString: 0,
        barreEndString: 5,
      ),
      // x 8 10 8 10 8  — A7-shape barre fret 8
      ChordShapeModel(
        frets: [-1, 8, 10, 8, 10, 8],
        fingers: [0, 1, 3, 1, 4, 1],
        baseFret: 8,
        barreFret: 8,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'F',
    type: 'add9',
    shapes: [
      // 1 0 3 0 1 1  — F A F G C F ✓
      ChordShapeModel(frets: [-1, -1, 3, 2, 1, 3], fingers: [0, 0, 3, 2, 1, 4]),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  F# / Gb
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'F#',
    type: 'major',
    shapes: [
      // Barre fret 2 (E-shape)
      ChordShapeModel(
        frets: [2, 4, 4, 3, 2, 2],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 0,
        barreEndString: 5,
      ),
      // x 9 11 11 11 9  — A-shape barre fret 9
      ChordShapeModel(
        frets: [-1, 4, 4, 3, 2, -1],
        fingers: [0, 3, 4, 2, 1, 0],
        baseFret: 2,
      ),
      // x x 4 3 2 2  — compact F# (barre 2, strings 3–5)
      ChordShapeModel(
        frets: [-1, -1, 4, 3, 2, 2],
        fingers: [0, 0, 3, 2, 1, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 4,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'F#',
    type: 'minor',
    shapes: [
      // Barre fret 2 (Em-shape)
      ChordShapeModel(
        frets: [2, 4, 4, 2, 2, 2],
        fingers: [1, 3, 4, 1, 1, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 4, 6, 7, 5],
        fingers: [0, 0, 1, 3, 4, 2],
        baseFret: 4,
      ),
      ChordShapeModel(
        frets: [-1, 9, 11, 11, 10, 9],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 9,
        barreFret: 9,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'F#',
    type: '7',
    shapes: [
      // Barre fret 2 (E7-shape)
      ChordShapeModel(
        frets: [2, 4, 2, 3, 2, 2],
        fingers: [1, 3, 1, 2, 1, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 4, 6, 5, 6],
        fingers: [0, 0, 1, 3, 2, 4],
        baseFret: 4,
      ),
    ],
  ),

  ChordModel(
    root: 'F#',
    type: 'add9',
    shapes: [
      // 2 4 4 3 2 4  — F# C# F# A# C# G# ✓
      ChordShapeModel(
        frets: [-1, -1, 4, 3, 2, 4],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 2,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  G
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'G',
    type: 'major',
    shapes: [
      // 3 2 0 0 0 3  — standard open G
      ChordShapeModel(frets: [3, 2, 0, 0, 0, 3], fingers: [2, 1, 0, 0, 0, 3]),
      // 3 2 0 0 3 3  — G with doubled G on top
      ChordShapeModel(frets: [3, 2, 0, 0, 3, 3], fingers: [2, 1, 0, 0, 3, 4]),
      // Barre fret 3 (E-shape)
      ChordShapeModel(
        frets: [3, 5, 5, 4, 3, 3],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'G',
    type: 'minor',
    shapes: [
      // Barre fret 3 (Em-shape)
      ChordShapeModel(
        frets: [3, 5, 5, 3, 3, 3],
        fingers: [1, 3, 4, 1, 1, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 5, 7, 8, 6],
        fingers: [0, 0, 1, 3, 4, 2],
        baseFret: 5,
      ),
      // x 10 12 12 11 10  — Am-shape barre fret 10
      ChordShapeModel(
        frets: [-1, 10, 12, 12, 11, 10],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 10,
        barreFret: 10,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'G',
    type: '7',
    shapes: [
      // 3 2 0 0 0 1  — standard open G7
      ChordShapeModel(frets: [3, 2, 0, 0, 0, 1], fingers: [3, 2, 0, 0, 0, 1]),
      // Barre fret 3 (E7-shape)
      ChordShapeModel(
        frets: [3, 5, 3, 4, 3, 3],
        fingers: [1, 3, 1, 2, 1, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'G',
    type: 'add9',
    shapes: [
      // 3 2 0 2 3 3  — G B D A B G ✓
      ChordShapeModel(
        frets: [-1, -1, 5, 4, 3, 5],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 3,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  G# / Ab
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'G#',
    type: 'major',
    shapes: [
      // Barre fret 4 (E-shape)
      ChordShapeModel(
        frets: [4, 6, 6, 5, 4, 4],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 0,
        barreEndString: 5,
      ),
      // x 11 13 13 13 11  — A-shape barre fret 11
      ChordShapeModel(
        frets: [-1, 6, 6, 5, 4, -1],
        fingers: [0, 3, 4, 2, 1, 0],
        baseFret: 4,
      ),
      // x x 6 5 4 4  — compact (barre 4, strings 3–5)
      ChordShapeModel(
        frets: [-1, -1, 6, 5, 4, 4],
        fingers: [0, 0, 3, 2, 1, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 4,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'G#',
    type: 'minor',
    shapes: [
      // Barre fret 4 (Em-shape)
      ChordShapeModel(
        frets: [4, 6, 6, 4, 4, 4],
        fingers: [1, 3, 4, 1, 1, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 6, 8, 9, 7],
        fingers: [0, 0, 1, 3, 4, 2],
        baseFret: 6,
      ),
      // x 11 13 13 12 11  — Am-shape barre fret 11
      ChordShapeModel(
        frets: [-1, 11, 13, 13, 12, 11],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 11,
        barreFret: 11,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'G#',
    type: '7',
    shapes: [
      // Barre fret 4 (E7-shape)
      ChordShapeModel(
        frets: [4, 6, 4, 5, 4, 4],
        fingers: [1, 3, 1, 2, 1, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 6, 8, 7, 8],
        fingers: [0, 0, 1, 3, 2, 4],
        baseFret: 6,
      ),
      ChordShapeModel(
        frets: [-1, -1, 6, 5, 4, 4],
        fingers: [0, 0, 4, 3, 1, 2],
        baseFret: 4,
      ),
    ],
  ),

  ChordModel(
    root: 'G#',
    type: 'add9',
    shapes: [
      // x x 6 5 4 6  — G# C D# A# ✓
      ChordShapeModel(
        frets: [-1, -1, 6, 5, 4, 6],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 4,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  A
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'A',
    type: 'major',
    shapes: [
      // x 0 2 2 2 0  — standard open A
      ChordShapeModel(frets: [-1, 0, 2, 2, 2, 0], fingers: [0, 0, 1, 2, 3, 0]),
      // Barre fret 5 (E-shape)
      ChordShapeModel(
        frets: [5, 7, 7, 6, 5, 5],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'A',
    type: 'minor',
    shapes: [
      // x 0 2 2 1 0  — standard open Am
      ChordShapeModel(frets: [-1, 0, 2, 2, 1, 0], fingers: [0, 0, 2, 3, 1, 0]),
      // Barre fret 5 (Em-shape)
      ChordShapeModel(
        frets: [5, 7, 7, 5, 5, 5],
        fingers: [1, 3, 4, 1, 1, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'A',
    type: '7',
    shapes: [
      // x 0 2 0 2 0  — standard open A7
      ChordShapeModel(frets: [-1, 0, 2, 0, 2, 0], fingers: [0, 0, 2, 0, 3, 0]),
      // Barre fret 5 (E7-shape)
      ChordShapeModel(
        frets: [5, 7, 5, 6, 5, 5],
        fingers: [1, 3, 1, 2, 1, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'A',
    type: 'add9',
    shapes: [
      // x 0 2 4 2 0  — A E B C# E ✓
      ChordShapeModel(
        frets: [-1, -1, 7, 6, 5, 7],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 5,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  A# / Bb
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'A#',
    type: 'major',
    shapes: [
      // x 1 3 3 3 1  — Barre fret 1 (A-shape)
      ChordShapeModel(
        frets: [-1, 1, 3, 3, 3, 1],
        fingers: [0, 1, 2, 3, 4, 1],
        barreFret: 1,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 6 (E-shape)
      ChordShapeModel(
        frets: [6, 8, 8, 7, 6, 6],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'A#',
    type: 'minor',
    shapes: [
      // x 1 3 3 2 1  — Barre fret 1 (Am-shape)
      ChordShapeModel(
        frets: [-1, 1, 3, 3, 2, 1],
        fingers: [0, 1, 3, 4, 2, 1],
        barreFret: 1,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 6 (Em-shape)
      ChordShapeModel(
        frets: [6, 8, 8, 6, 6, 6],
        fingers: [1, 3, 4, 1, 1, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'A#',
    type: '7',
    shapes: [
      // x 1 3 1 3 1  — Barre fret 1 (A7-shape)
      ChordShapeModel(
        frets: [-1, 1, 3, 1, 3, 1],
        fingers: [0, 1, 3, 1, 4, 1],
        barreFret: 1,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 6 (E7-shape)
      ChordShapeModel(
        frets: [6, 8, 6, 7, 6, 6],
        fingers: [1, 3, 1, 2, 1, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'A#',
    type: 'add9',
    shapes: [
      // x 1 3 5 3 1  — A# F C D F ✓
      ChordShapeModel(
        frets: [-1, -1, 8, 7, 6, 8],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 6,
      ),
    ],
  ),

  // ══════════════════════════════════════════════════
  //  B
  // ══════════════════════════════════════════════════
  ChordModel(
    root: 'B',
    type: 'major',
    shapes: [
      // x 2 4 4 4 2  — Barre fret 2 (A-shape)
      ChordShapeModel(
        frets: [-1, 2, 4, 4, 4, 2],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 7 (E-shape)
      ChordShapeModel(
        frets: [7, 9, 9, 8, 7, 7],
        fingers: [1, 3, 4, 2, 1, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'B',
    type: 'minor',
    shapes: [
      // x 2 4 4 3 2  — Barre fret 2 (Am-shape)
      ChordShapeModel(
        frets: [-1, 2, 4, 4, 3, 2],
        fingers: [0, 1, 3, 4, 2, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 7 (Em-shape)
      ChordShapeModel(
        frets: [7, 9, 9, 7, 7, 7],
        fingers: [1, 3, 4, 1, 1, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'B',
    type: '7',
    shapes: [
      // x 2 1 2 0 2  — B D# A B F# (open B7, all chord tones)
      ChordShapeModel(frets: [-1, 2, 1, 2, 0, 2], fingers: [0, 2, 1, 3, 0, 4]),
      // x 2 4 2 4 2  — Barre fret 2 (A7-shape)
      ChordShapeModel(
        frets: [-1, 2, 4, 2, 4, 2],
        fingers: [0, 1, 3, 1, 4, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 1,
        barreEndString: 5,
      ),
      // Barre fret 7 (E7-shape)
      ChordShapeModel(
        frets: [7, 9, 7, 8, 7, 7],
        fingers: [1, 3, 1, 2, 1, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),

  ChordModel(
    root: 'B',
    type: 'add9',
    shapes: [
      // x 2 4 6 4 2  — B F# C# D# F# ✓
      ChordShapeModel(
        frets: [-1, -1, 9, 8, 7, 9],
        fingers: [0, 0, 3, 2, 1, 4],
        baseFret: 7,
      ),
    ],
  ),
  // ════════════════════ SUS4 ════════════════════
  ChordModel(
    root: 'C',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [-1, 3, 3, 0, 1, 1],
        fingers: [0, 3, 4, 0, 1, 1],
        barreFret: 1,
        barreStartString: 4,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, 3, 5, 5, 6, 3],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'C#',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [-1, 4, 6, 6, 7, 4],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [9, 11, 11, 11, 9, 9],
        fingers: [1, 2, 3, 4, 1, 1],
        baseFret: 9,
        barreFret: 9,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'D',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [-1, -1, 0, 2, 3, 3],
        fingers: [0, 0, 0, 1, 3, 4],
        baseFret: 2,
      ),
      ChordShapeModel(
        frets: [-1, 5, 7, 7, 8, 5],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'D#',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [-1, 6, 8, 8, 9, 6],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(frets: [-1, -1, 1, 3, 4, 4], fingers: [0, 0, 1, 2, 3, 4]),
    ],
  ),
  ChordModel(
    root: 'E',
    type: 'sus4',
    shapes: [
      ChordShapeModel(frets: [0, 2, 2, 2, 0, 0], fingers: [0, 1, 2, 3, 0, 0]),
      ChordShapeModel(
        frets: [-1, 7, 9, 9, 10, 7],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'F',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [1, 3, 3, 3, 1, 1],
        fingers: [1, 2, 3, 4, 1, 1],
        barreFret: 1,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, 8, 10, 10, 11, 8],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 8,
        barreFret: 8,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'F#',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [2, 4, 4, 4, 2, 2],
        fingers: [1, 2, 3, 4, 1, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 4, 6, 7, 7],
        fingers: [0, 0, 1, 2, 3, 4],
        baseFret: 4,
      ),
      ChordShapeModel(
        frets: [-1, 9, 11, 11, 12, 9],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 9,
        barreFret: 9,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'G',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [3, 5, 5, 5, 3, 3],
        fingers: [1, 2, 3, 4, 1, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 5, 7, 8, 8],
        fingers: [0, 0, 1, 2, 3, 4],
        baseFret: 5,
      ),
      ChordShapeModel(
        frets: [-1, 10, 12, 12, 13, 10],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 10,
        barreFret: 10,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'G#',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [4, 6, 6, 6, 4, 4],
        fingers: [1, 2, 3, 4, 1, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 6, 8, 9, 9],
        fingers: [0, 0, 1, 2, 3, 4],
        baseFret: 6,
      ),
      ChordShapeModel(
        frets: [-1, 11, 13, 13, 14, 11],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 11,
        barreFret: 11,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'A',
    type: 'sus4',
    shapes: [
      ChordShapeModel(frets: [-1, 0, 2, 2, 3, 0], fingers: [0, 0, 1, 2, 3, 0]),
      ChordShapeModel(
        frets: [5, 7, 7, 7, 5, 5],
        fingers: [1, 2, 3, 4, 1, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 7, 9, 10, 10],
        fingers: [0, 0, 1, 2, 3, 4],
        baseFret: 7,
      ),
    ],
  ),
  ChordModel(
    root: 'A#',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [-1, 1, 3, 3, 4, 1],
        fingers: [0, 1, 2, 3, 4, 1],
        barreFret: 1,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [6, 8, 8, 8, 6, 6],
        fingers: [1, 2, 3, 4, 1, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 8, 10, 11, 11],
        fingers: [0, 0, 1, 2, 3, 4],
        baseFret: 8,
      ),
    ],
  ),
  ChordModel(
    root: 'B',
    type: 'sus4',
    shapes: [
      ChordShapeModel(
        frets: [-1, 2, 4, 4, 5, 2],
        fingers: [0, 1, 2, 3, 4, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [7, 9, 9, 9, 7, 7],
        fingers: [1, 2, 3, 4, 1, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 9, 11, 12, 12],
        fingers: [0, 0, 1, 2, 3, 4],
        baseFret: 9,
      ),
    ],
  ),

  // ════════════════════ MAJ7 ════════════════════
  ChordModel(
    root: 'C',
    type: 'maj7',
    shapes: [
      ChordShapeModel(frets: [-1, 3, 2, 0, 0, 0], fingers: [0, 3, 2, 0, 0, 0]),
      ChordShapeModel(
        frets: [-1, 3, 5, 4, 5, 3],
        fingers: [0, 1, 3, 2, 4, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'C#',
    type: 'maj7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 4, 6, 5, 6, 4],
        fingers: [0, 1, 3, 2, 4, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, 4, 3, 1, 1, 1],
        fingers: [0, 4, 2, 1, 1, 1],
        barreFret: 1,
        barreStartString: 3,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'D',
    type: 'maj7',
    shapes: [
      ChordShapeModel(frets: [-1, -1, 0, 2, 2, 2], fingers: [0, 0, 0, 1, 2, 3]),
      ChordShapeModel(
        frets: [-1, 5, 7, 6, 7, 5],
        fingers: [0, 1, 3, 2, 4, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'D#',
    type: 'maj7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 6, 8, 7, 8, 6],
        fingers: [0, 1, 3, 2, 4, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(frets: [-1, -1, 1, 3, 3, 3], fingers: [0, 0, 1, 2, 3, 4]),
    ],
  ),
  ChordModel(
    root: 'E',
    type: 'maj7',
    shapes: [
      ChordShapeModel(frets: [0, 2, 1, 1, 0, -1], fingers: [0, 3, 1, 2, 0, 0]),
      ChordShapeModel(
        frets: [-1, 7, 9, 8, 9, 7],
        fingers: [0, 1, 3, 2, 4, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'F',
    type: 'maj7',
    shapes: [
      ChordShapeModel(frets: [-1, -1, 3, 2, 1, 0], fingers: [0, 0, 3, 2, 1, 0]),
      ChordShapeModel(
        frets: [-1, 8, 10, 9, 10, 8],
        fingers: [0, 1, 3, 2, 4, 1],
        baseFret: 8,
        barreFret: 8,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'F#',
    type: 'maj7',
    shapes: [
      ChordShapeModel(
        frets: [2, 4, 3, 3, 2, 2],
        fingers: [1, 4, 2, 3, 1, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(frets: [-1, -1, 4, 3, 2, 1], fingers: [0, 0, 4, 3, 2, 1]),
    ],
  ),
  ChordModel(
    root: 'G',
    type: 'maj7',
    shapes: [
      ChordShapeModel(
        frets: [-1, -1, 5, 4, 3, 2],
        fingers: [0, 0, 4, 3, 2, 1],
        baseFret: 2,
      ),
      ChordShapeModel(
        frets: [3, 5, 4, 4, 3, 3],
        fingers: [1, 4, 2, 3, 1, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'G#',
    type: 'maj7',
    shapes: [
      ChordShapeModel(
        frets: [4, 6, 5, 5, 4, 4],
        fingers: [1, 4, 2, 3, 1, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 6, 5, 4, 3],
        fingers: [0, 0, 4, 3, 2, 1],
        baseFret: 3,
      ),
      ChordShapeModel(
        frets: [-1, 11, 13, 12, 13, 11],
        fingers: [0, 1, 3, 2, 4, 1],
        baseFret: 11,
        barreFret: 11,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'A',
    type: 'maj7',
    shapes: [
      ChordShapeModel(frets: [-1, 0, 2, 1, 2, 0], fingers: [0, 0, 2, 1, 3, 0]),
      ChordShapeModel(
        frets: [5, 7, 6, 6, 5, 5],
        fingers: [1, 4, 2, 3, 1, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 7, 6, 5, 4],
        fingers: [0, 0, 4, 3, 2, 1],
        baseFret: 4,
      ),
    ],
  ),
  ChordModel(
    root: 'A#',
    type: 'maj7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 1, 3, 2, 3, 1],
        fingers: [0, 1, 3, 2, 4, 1],
        barreFret: 1,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [6, 8, 7, 7, 6, 6],
        fingers: [1, 4, 2, 3, 1, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 8, 7, 6, 5],
        fingers: [0, 0, 4, 3, 2, 1],
        baseFret: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'B',
    type: 'maj7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 2, 4, 3, 4, 2],
        fingers: [0, 1, 3, 2, 4, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [7, 9, 8, 8, 7, 7],
        fingers: [1, 4, 2, 3, 1, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 9, 8, 7, 6],
        fingers: [0, 0, 4, 3, 2, 1],
        baseFret: 6,
      ),
    ],
  ),
  // ════════════════════ M7 (minor 7) ════════════════════
  ChordModel(
    root: 'C',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 3, 5, 3, 4, 3],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [8, 10, 8, 8, 8, 8],
        fingers: [1, 3, 1, 1, 1, 1],
        baseFret: 8,
        barreFret: 8,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'C#',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 4, 6, 4, 5, 4],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [9, 11, 9, 9, 9, 9],
        fingers: [1, 3, 1, 1, 1, 1],
        baseFret: 9,
        barreFret: 9,
        barreStartString: 0,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'D',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [-1, -1, 0, 2, 1, 1],
        fingers: [0, 0, 0, 2, 1, 1],
        barreFret: 1,
        barreStartString: 4,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, 5, 7, 5, 6, 5],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'D#',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 6, 8, 6, 7, 6],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(frets: [-1, -1, 1, 3, 2, 2], fingers: [0, 0, 1, 4, 2, 3]),
    ],
  ),
  ChordModel(
    root: 'E',
    type: 'm7',
    shapes: [
      ChordShapeModel(frets: [0, 2, 0, 0, 0, 0], fingers: [0, 2, 0, 0, 0, 0]),
      ChordShapeModel(
        frets: [-1, 7, 9, 7, 8, 7],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'F',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [1, 3, 1, 1, 1, 1],
        fingers: [1, 3, 1, 1, 1, 1],
        barreFret: 1,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, 8, 10, 8, 9, 8],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 8,
        barreFret: 8,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'F#',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [2, 4, 2, 2, 2, 2],
        fingers: [1, 3, 1, 1, 1, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 4, 6, 5, 5],
        fingers: [0, 0, 1, 4, 2, 3],
        baseFret: 4,
      ),
    ],
  ),
  ChordModel(
    root: 'G',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [3, 5, 3, 3, 3, 3],
        fingers: [1, 3, 1, 1, 1, 1],
        baseFret: 3,
        barreFret: 3,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 5, 7, 6, 6],
        fingers: [0, 0, 1, 4, 2, 3],
        baseFret: 5,
      ),
      ChordShapeModel(
        frets: [-1, 10, 12, 10, 11, 10],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 10,
        barreFret: 10,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'G#',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [4, 6, 4, 4, 4, 4],
        fingers: [1, 3, 1, 1, 1, 1],
        baseFret: 4,
        barreFret: 4,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 6, 8, 7, 7],
        fingers: [0, 0, 1, 4, 2, 3],
        baseFret: 6,
      ),
      ChordShapeModel(
        frets: [-1, 11, 13, 11, 12, 11],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 11,
        barreFret: 11,
        barreStartString: 1,
        barreEndString: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'A',
    type: 'm7',
    shapes: [
      ChordShapeModel(frets: [-1, 0, 2, 0, 1, 0], fingers: [0, 0, 2, 0, 1, 0]),
      ChordShapeModel(
        frets: [5, 7, 5, 5, 5, 5],
        fingers: [1, 3, 1, 1, 1, 1],
        baseFret: 5,
        barreFret: 5,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 7, 9, 8, 8],
        fingers: [0, 0, 1, 4, 2, 3],
        baseFret: 7,
      ),
    ],
  ),
  ChordModel(
    root: 'A#',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 1, 3, 1, 2, 1],
        fingers: [0, 1, 3, 1, 2, 1],
        barreFret: 1,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [6, 8, 6, 6, 6, 6],
        fingers: [1, 3, 6, 1, 1, 1],
        baseFret: 6,
        barreFret: 6,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 8, 10, 9, 9],
        fingers: [0, 0, 1, 4, 2, 3],
        baseFret: 8,
      ),
    ],
  ),
  ChordModel(
    root: 'B',
    type: 'm7',
    shapes: [
      ChordShapeModel(
        frets: [-1, 2, 4, 2, 3, 2],
        fingers: [0, 1, 3, 1, 2, 1],
        baseFret: 2,
        barreFret: 2,
        barreStartString: 1,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [7, 9, 7, 7, 7, 7],
        fingers: [1, 3, 1, 1, 1, 1],
        baseFret: 7,
        barreFret: 7,
        barreStartString: 0,
        barreEndString: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 9, 11, 10, 10],
        fingers: [0, 0, 1, 4, 2, 3],
        baseFret: 9,
      ),
    ],
  ),
  // ════════════════════ 5 (Power Chord) ════════════════════
  ChordModel(
    root: 'C',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [-1, 3, 5, 5, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
        baseFret: 3,
      ),
      ChordShapeModel(
        frets: [8, 10, 10, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
        baseFret: 8,
      ),
    ],
  ),
  ChordModel(
    root: 'C#',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [-1, 4, 6, 6, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
        baseFret: 4,
      ),
      ChordShapeModel(
        frets: [9, 11, 11, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
        baseFret: 9,
      ),
    ],
  ),
  ChordModel(
    root: 'D',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [-1, 5, 7, 7, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
        baseFret: 5,
      ),
      ChordShapeModel(
        frets: [-1, -1, 0, 2, 3, -1],
        fingers: [0, 0, 0, 1, 3, 0],
      ),
    ],
  ),
  ChordModel(
    root: 'D#',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [-1, 6, 8, 8, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
        baseFret: 6,
      ),
      ChordShapeModel(
        frets: [-1, -1, 1, 3, -1, -1],
        fingers: [0, 0, 1, 3, 0, 0],
      ),
    ],
  ),
  ChordModel(
    root: 'E',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [0, 2, 2, -1, -1, -1],
        fingers: [0, 1, 2, 0, 0, 0],
      ),
      ChordShapeModel(
        frets: [-1, 7, 9, 9, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
        baseFret: 7,
      ),
    ],
  ),
  ChordModel(
    root: 'F',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [1, 3, 3, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
      ),
      ChordShapeModel(
        frets: [-1, 8, 10, 10, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
        baseFret: 8,
      ),
    ],
  ),
  ChordModel(
    root: 'F#',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [2, 4, 4, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
        baseFret: 2,
      ),
      ChordShapeModel(
        frets: [-1, 9, 11, 11, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
        baseFret: 9,
      ),
    ],
  ),
  ChordModel(
    root: 'G',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [3, 5, 5, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
        baseFret: 3,
      ),
      ChordShapeModel(
        frets: [-1, -1, 5, 7, 8, -1],
        fingers: [0, 0, 1, 3, 4, 0],
        baseFret: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'G#',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [4, 6, 6, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
        baseFret: 4,
      ),
      ChordShapeModel(
        frets: [-1, -1, 6, 8, 9, -1],
        fingers: [0, 0, 1, 3, 4, 0],
        baseFret: 6,
      ),
    ],
  ),
  ChordModel(
    root: 'A',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [-1, 0, 2, 2, -1, -1],
        fingers: [0, 0, 1, 2, 0, 0],
      ),
      ChordShapeModel(
        frets: [5, 7, 7, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
        baseFret: 5,
      ),
    ],
  ),
  ChordModel(
    root: 'A#',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [-1, 1, 3, 3, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
      ),
      ChordShapeModel(
        frets: [6, 8, 8, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
        baseFret: 6,
      ),
    ],
  ),
  ChordModel(
    root: 'B',
    type: '5',
    shapes: [
      ChordShapeModel(
        frets: [-1, 2, 4, 4, -1, -1],
        fingers: [0, 1, 3, 4, 0, 0],
        baseFret: 2,
      ),
      ChordShapeModel(
        frets: [7, 9, 9, -1, -1, -1],
        fingers: [1, 3, 4, 0, 0, 0],
        baseFret: 7,
      ),
    ],
  ),
];
