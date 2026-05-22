import '../models/barre_info.dart';
import '../models/finger_position.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BarreInferencer
//
// Menganalisis dots yang ditempatkan user dan menginfer barre secara otomatis.
//
// Aturan inferensi barre:
//   1. Kumpulkan dots yang berada di fret yang sama.
//   2. Jika ada ≥ 2 dot di fret yang sama DAN string-nya BERURUTAN (consecutive),
//      anggap sebagai barre → gambar bar, assign finger = 1 (telunjuk).
//   3. Dots yang ada di fret lain (non-barre) mendapat finger 2,3,4 secara urut.
//   4. Jika ada dua grup barre berbeda fret, grup fret terkecil = barre utama (finger 1),
//      grup berikutnya = mini-barre (finger 2), dst — hingga max finger 4.
//
// Output:
//   • List<BarreInfo>        → untuk dirender sebagai bar merah
//   • List<FingerPosition>   → dots yang TIDAK tercakup barre (dengan finger terisi)
// ─────────────────────────────────────────────────────────────────────────────

class BarreInferenceResult {
  final List<BarreInfo> barres;

  /// Dots yang TIDAK di-cover barre, sudah dilengkapi finger number (1–4).
  final List<FingerPosition> remainingDots;

  const BarreInferenceResult({
    required this.barres,
    required this.remainingDots,
  });
}

class BarreInferencer {
  /// [dots] — posisi yang ditempatkan user (finger boleh 0).
  /// [baseFret] — fret pertama yang ditampilkan di layar.
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

    // ── 2. Cari fret-fret yang membentuk barre (≥2 string berurutan) ────────
    final List<_BarreCandidate> candidates = [];

    for (final entry in byFret.entries) {
      final fret = entry.key;
      final strings = List<int>.from(entry.value)..sort();

      // Cari run terpanjang yang berurutan
      int runStart = 0;
      for (int i = 1; i <= strings.length; i++) {
        final isEnd = i == strings.length;
        final isBreak = !isEnd && strings[i] != strings[i - 1] + 1;

        if (isEnd || isBreak) {
          final runLen = i - runStart;
          if (runLen >= 2) {
            candidates.add(_BarreCandidate(
              fret: fret,
              startString: strings[runStart],
              endString: strings[i - 1],
              count: runLen,
            ));
          }
          runStart = i;
        }
      }
    }

    // ── 3. Urutkan kandidat: fret terkecil dulu (barre utama = telunjuk) ────
    candidates.sort((a, b) => a.fret.compareTo(b.fret));

    // Batasi: max 2 barre aktif (jari 1 dan 2); di atas itu anggap individual dots
    final activeCandidates = candidates.take(2).toList();

    // ── 4. Bangun BarreInfo dengan finger assignment ─────────────────────────
    final barres = <BarreInfo>[];
    int nextFingerForBarre = 1;

    for (final c in activeCandidates) {
      barres.add(BarreInfo(
        finger: nextFingerForBarre,
        fret: c.fret,
        startString: c.startString,
        endString: c.endString,
      ));
      nextFingerForBarre++;
    }

    // ── 5. Kumpulkan string yang di-cover barre ──────────────────────────────
    final Set<String> barreCovered = {};
    for (final b in barres) {
      for (int s = b.startString; s <= b.endString; s++) {
        barreCovered.add('${s}_${b.fret}');
      }
    }

    // ── 6. Dots yang tidak tercakup barre → assign finger 2/3/4 secara urut ─
    final remaining = <FingerPosition>[];
    int nextFingerForDot = nextFingerForBarre; // lanjut dari setelah barre finger

    for (final d in dots) {
      final key = '${d.string}_${d.fret}';
      if (barreCovered.contains(key)) continue;

      final finger = nextFingerForDot <= 4 ? nextFingerForDot : 4;
      nextFingerForDot++;

      remaining.add(FingerPosition(
        string: d.string,
        fret: d.fret,
        finger: finger,
      ));
    }

    return BarreInferenceResult(barres: barres, remainingDots: remaining);
  }
}

class _BarreCandidate {
  final int fret;
  final int startString;
  final int endString;
  final int count;

  const _BarreCandidate({
    required this.fret,
    required this.startString,
    required this.endString,
    required this.count,
  });
}
