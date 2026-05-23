import '../models/barre_info.dart';
import '../models/finger_position.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BarreInferencer
//
// Mendeteksi barre dari pola dots user, mengikuti prinsip chord_library.dart.
//
// ══ RULE BARRE ══
//
// Barre valid jika fret TERENDAH (fretMin) memenuhi SEMUA syarat:
//   1. Punya >= 2 dots
//   2. span (sMax - sMin + 1) >= 4   ← minimum jangkauan barre nyata
//   3. Salah satu dari:
//      a. Ada GAP di anchor strings (span > count)         → contoh: F, Cm, Bm
//      b. Ada dot INTERIOR di fret lain antara sMin..sMax  → contoh: Cm, B
//
// Kenapa span >= 4 penting:
//   Chord D (frets: -1,-1,0,2,3,2) → dots [(3,2),(4,3),(5,2)]
//   Anchor di fret 2: strings [3,5] → span=3, ada interior di string 4 fret 3
//   Tanpa filter span, D dianggap barre — SALAH.
//   Span=3 terlalu sempit untuk barre nyata (min barre = 4 string).
//
// Semua barre nyata di library punya span >= 4:
//   Am-shape (Cm,Bm,B): anchor [1,5] → span=5 ✓
//   E-shape  (F,Fm,G):  anchor [0,5] → span=6 ✓
//   Half-barre (Bb):    anchor [0,5] → span=6 ✓
// ─────────────────────────────────────────────────────────────────────────────

class BarreInferenceResult {
  final List<BarreInfo> barres;
  final List<FingerPosition> remainingDots;

  const BarreInferenceResult({
    required this.barres,
    required this.remainingDots,
  });
}

class BarreInferencer {
  // Minimum span anchor strings untuk dianggap barre.
  // 4 = minimal barre mencakup 4 string (sempit), 6 = full 6 string.
  // Semua barre di chord_library punya span 5 atau 6 → threshold 4 aman.
  static const int _minBarreSpan = 4;

  static BarreInferenceResult infer(
    List<FingerPosition> dots, {
    int baseFret = 1,
  }) {
    if (dots.isEmpty) {
      return const BarreInferenceResult(barres: [], remainingDots: []);
    }

    // ── 1. Kelompokkan dots per fret ────────────────────────────────────────
    final Map<int, List<int>> byFret = {};
    for (final d in dots) {
      byFret.putIfAbsent(d.fret, () => []).add(d.string);
    }

    // ── 2. Fret terendah = kandidat anchor barre ────────────────────────────
    final int fretMin =
        byFret.keys.reduce((a, b) => a < b ? a : b);
    final List<int> anchorStrings =
        List<int>.from(byFret[fretMin]!)..sort();

    // ── 3. Validasi barre ───────────────────────────────────────────────────
    BarreInfo? barre;

    if (anchorStrings.length >= 2) {
      final int sMin  = anchorStrings.first;
      final int sMax  = anchorStrings.last;
      final int span  = sMax - sMin + 1;
      final int count = anchorStrings.length;

      // Syarat span minimum — filter chord seperti D (span=3)
      if (span >= _minBarreSpan) {
        // Kondisi a: ada gap di anchor strings
        final bool hasGap = span > count;

        // Kondisi b: ada dot interior (fret lain, string antara sMin..sMax)
        final bool hasInterior = dots.any(
          (d) => d.fret != fretMin && d.string > sMin && d.string < sMax,
        );

        if (hasGap || hasInterior) {
          barre = BarreInfo(
            finger: 1,
            fret: fretMin,
            startString: sMin,
            endString: sMax,
          );
        }
      }
    }

    // ── 4. Bangun remainingDots ──────────────────────────────────────────────
    final List<FingerPosition> remaining = [];
    int nextFinger = barre != null ? 2 : 1;

    for (final d in dots) {
      // Skip jika di-cover barre
      if (barre != null &&
          d.fret == barre.fret &&
          d.string >= barre.startString &&
          d.string <= barre.endString) {
        continue;
      }

      final finger = nextFinger <= 4 ? nextFinger : 4;
      nextFinger++;

      remaining.add(FingerPosition(
        string: d.string,
        fret: d.fret,
        finger: finger,
      ));
    }

    return BarreInferenceResult(
      barres: barre != null ? [barre] : [],
      remainingDots: remaining,
    );
  }
}