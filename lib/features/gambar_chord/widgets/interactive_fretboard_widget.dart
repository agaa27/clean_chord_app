import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model posisi dot user.
// string : 0 = low E … 5 = high e
// fret   : fret ABSOLUT (1-based dari kepala gitar).
//          Fret 0 tidak digunakan di sini — open string dihitung oleh validasi,
//          bukan oleh dot yang user taruh.
// ─────────────────────────────────────────────────────────────────────────────
class FingerPosition {
  final int string;
  final int fret; // absolut, 1-based
  const FingerPosition({required this.string, required this.fret});

  @override
  bool operator ==(Object other) =>
      other is FingerPosition &&
      other.string == string &&
      other.fret == fret;

  @override
  int get hashCode => Object.hash(string, fret);
}

// ─────────────────────────────────────────────────────────────────────────────
// Warna dot — identik dengan chord_fretboard_widget asli
// ─────────────────────────────────────────────────────────────────────────────
const _dotColors = <int, Color>{
  0: Color(0xFFFF4C4C),
  1: Color(0xFF4C9EFF),
  2: Color(0xFF00E676),
  3: Color(0xFFFFAA00),
};
Color _dotColor(int idx) => _dotColors[idx % 4]!;

// ─────────────────────────────────────────────────────────────────────────────
// InteractiveFretboardWidget
//
// Visual identik dengan ChordFretboardWidget (nut, fret, senar, dot, glow).
// Perbedaan: user bisa tap sel untuk pasang/pindah/hapus dot.
//
// callback onTap(string, fret):
//   - fret adalah fret ABSOLUT (baseFret + row).
//   - Game page yang memutuskan apakah tap itu pasang/pindah/hapus.
// ─────────────────────────────────────────────────────────────────────────────
class InteractiveFretboardWidget extends StatelessWidget {
  final List<FingerPosition> placedDots;
  final List<bool>           mutedStrings; // length 6, index 0 = low E
  final void Function(int string, int fret) onTap;
  final bool             reviewMode;
  final Map<int, Color>  reviewColors; // string → warna (hijau/merah)
  final int              baseFret;     // fret pertama yang ditampilkan

  const InteractiveFretboardWidget({
    super.key,
    required this.placedDots,
    required this.mutedStrings,
    required this.onTap,
    this.reviewMode   = false,
    this.reviewColors = const {},
    this.baseFret     = 1,
  });

  static const int _strings = 6;
  static const int _frets   = 5;

  // Konversi koordinat lokal → (string, fret absolut).
  // Mengembalikan null jika tap di luar area grid.
  ({int string, int fret})? _hit(
    Offset local,
    double leftPad, double topPad,
    double strSp, double fretSp,
  ) {
    final x = local.dx - leftPad;
    final y = local.dy - topPad;

    // Toleransi horizontal: setengah jarak antar senar di kiri/kanan tepi
    if (x < -strSp / 2 || x > (_strings - 1) * strSp + strSp / 2) return null;
    if (y < 0 || y >= _frets * fretSp) return null;

    final s   = (x / strSp).round().clamp(0, _strings - 1);
    final row = (y / fretSp).floor().clamp(0, _frets - 1);
    return (string: s, fret: baseFret + row);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      const double leftPad   = 24.0;
      const double rightPad  = 10.0;
      // topPad = 8 identik dengan ChordFretboard painter.
      // Simbol X/O sekarang di Widget Row terpisah di atas painter,
      // persis seperti ChordFretboardWidget._buildTopRow().
      const double topPad    = 8.0;
      const double bottomPad = 4.0;

      final usableW = constraints.maxWidth  - leftPad - rightPad;
      final usableH = constraints.maxHeight - topPad  - bottomPad;
      final strSp   = usableW / (_strings - 1);
      final fretSp  = usableH / _frets;

      return Column(
        children: [
          // ── Baris X / O — identik dengan ChordFretboard._buildTopRow ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_strings, (i) {
              final hasDot = placedDots.any((d) => d.string == i);
              final String symbol;
              final Color  color;
              if (mutedStrings[i]) {
                symbol = '✕';
                color  = Colors.redAccent;
              } else if (!hasDot) {
                symbol = '○';
                color  = Colors.white54;
              } else {
                symbol = '';
                color  = Colors.transparent;
              }
              return SizedBox(
                width: strSp,
                child: Center(
                  child: Text(symbol,
                    style: TextStyle(color: color, fontSize: 13,
                        fontWeight: FontWeight.bold)),
                ),
              );
            }),
          ),
          const SizedBox(height: 2),
          // ── Fretboard painter ──────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTapUp: (d) {
                final hit = _hit(
                    d.localPosition, leftPad, topPad, strSp, fretSp);
                if (hit == null) return;
                HapticFeedback.selectionClick();
                onTap(hit.string, hit.fret);
              },
              child: CustomPaint(
                size: Size(constraints.maxWidth, double.infinity),
                painter: _FretboardPainter(
                  placedDots:   placedDots,
                  mutedStrings: mutedStrings,
                  baseFret:     baseFret,
                  reviewMode:   reviewMode,
                  reviewColors: reviewColors,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter — visual identik dengan _FretboardPainter di pustaka_chord
// ─────────────────────────────────────────────────────────────────────────────
class _FretboardPainter extends CustomPainter {
  final List<FingerPosition> placedDots;
  final List<bool>           mutedStrings;
  final int                  baseFret;
  final bool                 reviewMode;
  final Map<int, Color>      reviewColors;

  const _FretboardPainter({
    required this.placedDots,
    required this.mutedStrings,
    required this.baseFret,
    required this.reviewMode,
    required this.reviewColors,
  });

  static const _strings = 6;
  static const _frets   = 5;
  // Padding IDENTIK dengan ChordFretboard painter
  // topPad = 8 karena simbol X/O sekarang ada di Widget terpisah (_buildTopRow),
  // bukan di dalam painter — persis seperti ChordFretboardWidget
  static const leftPad   = 24.0;
  static const rightPad  = 10.0;
  static const topPad    = 8.0;
  static const bottomPad = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final usableW = size.width  - leftPad - rightPad;
    final usableH = size.height - topPad  - bottomPad;
    final strSp   = usableW / (_strings - 1);
    final fretSp  = usableH / _frets;
    final nutY    = topPad;

    // ── Nut ────────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(leftPad, nutY),
      Offset(leftPad + usableW, nutY),
      Paint()
        ..color       = baseFret == 1 ? Colors.white : Colors.white38
        ..strokeWidth = baseFret == 1 ? 5.0 : 1.5,
    );

    // ── Garis fret ──────────────────────────────────────────────────────
    final fretPaint = Paint()
      ..color       = Colors.white24
      ..strokeWidth = 1.0;
    for (int i = 1; i <= _frets; i++) {
      final dy = nutY + i * fretSp;
      canvas.drawLine(
          Offset(leftPad, dy), Offset(leftPad + usableW, dy), fretPaint);
    }

    // ── Senar ───────────────────────────────────────────────────────────
    for (int i = 0; i < _strings; i++) {
      final dx = leftPad + i * strSp;
      canvas.drawLine(
        Offset(dx, nutY),
        Offset(dx, nutY + _frets * fretSp),
        Paint()
          ..color       = Colors.white38
          ..strokeWidth = 1.0 + i * 0.22,
      );
    }

    // ── Label nomor fret (kalau bukan open position) ────────────────────
    if (baseFret > 1) {
      _text(canvas, '${baseFret}fr',
          Offset(2, nutY + fretSp * 0.5),
          const TextStyle(color: Colors.white70, fontSize: 11,
              fontWeight: FontWeight.w600),
          cx: false, cy: true);
    }

    // X/O sudah dirender di Widget Row terpisah di atas painter.
    // Painter tidak perlu render X/O — identik dengan ChordFretboard.

    // ── Grid tap-area (hint visual halus) ──────────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.018)
      ..style = PaintingStyle.fill;
    for (int s = 0; s < _strings; s++) {
      for (int f = 0; f < _frets; f++) {
        final cx = leftPad + s * strSp;
        final cy = nutY + (f + 0.5) * fretSp;
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset(cx, cy),
              width: strSp * 0.85, height: fretSp * 0.85),
          gridPaint,
        );
      }
    }

    // ── Barre bar ────────────────────────────────────────────────────────
    final fretCount = <int, List<int>>{};
    for (final d in placedDots) {
      fretCount.putIfAbsent(d.fret, () => []).add(d.string);
    }

    // ── Barre detection: hanya segment BERURUTAN (continuous index) ──────
    // Setiap fret dipecah menjadi segment-segment continuous.
    // Segment valid sebagai barre hanya jika panjang >= 2.
    // Gap/lompatan string → pisah jadi segment berbeda, tidak di-merge.
    final barreStrings = <int>{};

    // Helper: ekstrak semua segment continuous dari list string (sudah sorted)
    List<List<int>> _getConsecutiveSegments(List<int> sorted) {
      final segments = <List<int>>[];
      if (sorted.isEmpty) return segments;
      var current = [sorted.first];
      for (int k = 1; k < sorted.length; k++) {
        if (sorted[k] == sorted[k - 1] + 1) {
          current.add(sorted[k]);
        } else {
          segments.add(current);
          current = [sorted[k]];
        }
      }
      segments.add(current);
      return segments;
    }

    for (final entry in fretCount.entries) {
      final absFret = entry.key;
      final strings = entry.value..sort();
      final row = absFret - baseFret;
      if (row < 0 || row >= _frets) continue;

      final segments = _getConsecutiveSegments(strings);
      const barreCol = Color(0xFFFF4C4C);

      for (final seg in segments) {
        if (seg.length < 2) continue; // bukan barre jika hanya 1 string

        barreStrings.addAll(seg);

        final dy     = nutY + (row + 0.5) * fretSp;
        final xStart = leftPad + seg.first * strSp;
        final xEnd   = leftPad + seg.last  * strSp;

        // Glow
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(Offset(xStart - 8, dy - 13), Offset(xEnd + 8, dy + 13)),
            const Radius.circular(12),
          ),
          Paint()
            ..color      = barreCol.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );
        // Bar
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(Offset(xStart - 7, dy - 11), Offset(xEnd + 7, dy + 11)),
            const Radius.circular(11),
          ),
          Paint()..color = barreCol.withValues(alpha: 0.9),
        );
        // Label "1" di tengah bar
        _text(canvas, '1', Offset((xStart + xEnd) / 2, dy),
            const TextStyle(color: Colors.black, fontSize: 12,
                fontWeight: FontWeight.bold),
            cx: true, cy: true);
      }
    }

    final nonBarreDots = placedDots.where((d) => !barreStrings.contains(d.string)).toList();
    final sortedByPos  = List<FingerPosition>.from(nonBarreDots)
      ..sort((a, b) {
        final ra = a.fret - baseFret;
        final rb = b.fret - baseFret;
        return ra != rb ? ra.compareTo(rb) : a.string.compareTo(b.string);
      });
    final fingerNum = <FingerPosition, int>{};
    // Mulai dari 2 karena 1 sudah dipakai barre
    final hasAnyBarre = barreStrings.isNotEmpty;
    for (int n = 0; n < sortedByPos.length; n++) {
      fingerNum[sortedByPos[n]] = hasAnyBarre ? n + 2 : n + 1;
    }

    for (final dot in nonBarreDots) {
      final row = dot.fret - baseFret;
      if (row < 0 || row >= _frets) continue;

      final dx = leftPad + dot.string * strSp;
      final dy = nutY + (row + 0.5) * fretSp;

      final Color color;
      if (reviewMode && reviewColors.containsKey(dot.string)) {
        color = reviewColors[dot.string]!;
      } else {
        color = _dotColor(fingerNum[dot] ?? 1);
      }

      // Glow
      canvas.drawCircle(Offset(dx, dy), 16,
          Paint()
            ..color      = color.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      // Dot
      canvas.drawCircle(Offset(dx, dy), 13, Paint()..color = color);
      // Nomor
      final num = fingerNum[dot] ?? 1;
      _text(canvas, '$num', Offset(dx, dy),
          const TextStyle(color: Colors.black, fontSize: 12,
              fontWeight: FontWeight.bold),
          cx: true, cy: true);
    }
  }

  void _text(
    Canvas canvas, String txt, Offset pos, TextStyle style, {
    bool cx = false, bool cy = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: txt, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = cx ? pos.dx - tp.width  / 2 : pos.dx;
    final dy = cy ? pos.dy - tp.height / 2 : pos.dy;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_FretboardPainter o) =>
      o.placedDots   != placedDots   ||
      o.mutedStrings != mutedStrings ||
      o.baseFret     != baseFret     ||
      o.reviewMode   != reviewMode   ||
      o.reviewColors != reviewColors;
}