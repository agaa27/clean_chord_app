import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model posisi dot user
// string : 0 = low E … 5 = high e  (kiri ke kanan di fretboard)
// fret   : 0 = open string (tidak ditekan), 1–N = fret absolut
// ─────────────────────────────────────────────────────────────────────────────
class FingerPosition {
  final int string;
  final int fret; // 0 = open, 1+ = fret absolut
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
// Warna dot — identik dengan chord_fretboard_widget.dart
// ─────────────────────────────────────────────────────────────────────────────
const _kFingerColors = <int, Color>{
  1: Color(0xFFFF4C4C),
  2: Color(0xFF4C9EFF),
  3: Color(0xFF00E676),
  4: Color(0xFFFFAA00),
};
Color _dotColor(int idx) => _kFingerColors[(idx % 4) + 1]!;

// ─────────────────────────────────────────────────────────────────────────────
// InteractiveFretboardWidget
//
// Tampilan sepenuhnya mengikuti chord_fretboard_widget.dart (warna, ukuran,
// proporsi, nut, garis fret, garis senar, dot ukuran 13, glow, teks).
//
// Perbedaan dari widget asli:
//   • User bisa tap setiap sel untuk menaruh / memindah / menghapus dot
//   • Baris "mute" (E A D G B e) ada di luar widget ini, dikelola game page
//   • Dot open-string (fret 0) tidak divisualisasikan di badan fretboard,
//     melainkan ditandai dengan lingkaran ○ di atas nut (sama dengan widget asli)
// ─────────────────────────────────────────────────────────────────────────────
class InteractiveFretboardWidget extends StatelessWidget {
  final List<FingerPosition> placedDots;
  final List<bool> mutedStrings;     // length 6, index 0=low E
  final void Function(int string, int fret) onTap; // fret 1-based dari UI
  final bool reviewMode;
  final Map<int, Color> reviewColors; // string → warna review
  final int baseFret;                 // fret pertama yang ditampilkan

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

  // Hit-test: koordinat lokal → (string, fret absolut 1-based)
  ({int string, int fret})? _hitTest(
      Offset local, double leftPad, double topPad,
      double strSp, double fretSp) {
    final double x = local.dx - leftPad;
    final double y = local.dy - topPad;
    if (y < -topPad || x < -leftPad / 2) return null;

    final int s   = (x / strSp).round().clamp(0, _strings - 1);
    final int row = y ~/ fretSp; // 0-based row
    if (row < 0 || row >= _frets) return null;
    return (string: s, fret: row + baseFret);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      const double leftPad   = 24.0;
      const double rightPad  = 10.0;
      const double topPad    = 8.0;
      const double bottomPad = 4.0;

      final double usableW = constraints.maxWidth  - leftPad - rightPad;
      final double usableH = constraints.maxHeight - topPad  - bottomPad;
      final double strSp   = usableW / (_strings - 1);
      final double fretSp  = usableH / _frets;

      return GestureDetector(
        onTapUp: (d) {
          final hit = _hitTest(
              d.localPosition, leftPad, topPad, strSp, fretSp);
          if (hit == null) return;
          HapticFeedback.selectionClick();
          onTap(hit.string, hit.fret);
        },
        child: CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _InteractivePainter(
            placedDots:   placedDots,
            mutedStrings: mutedStrings,
            baseFret:     baseFret,
            reviewMode:   reviewMode,
            reviewColors: reviewColors,
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter — tampilan identik dengan _FretboardPainter di pustaka_chord
// ─────────────────────────────────────────────────────────────────────────────
class _InteractivePainter extends CustomPainter {
  final List<FingerPosition> placedDots;
  final List<bool> mutedStrings;
  final int baseFret;
  final bool reviewMode;
  final Map<int, Color> reviewColors;

  const _InteractivePainter({
    required this.placedDots,
    required this.mutedStrings,
    required this.baseFret,
    required this.reviewMode,
    required this.reviewColors,
  });

  static const int _strings = 6;
  static const int _frets   = 5;

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad   = 24.0;
    const double rightPad  = 10.0;
    const double topPad    = 8.0;
    const double bottomPad = 4.0;

    final double usableW = size.width  - leftPad - rightPad;
    final double usableH = size.height - topPad  - bottomPad;
    final double strSp   = usableW / (_strings - 1);
    final double fretSp  = usableH / _frets;
    final double nutY    = topPad;

    // ── Nut ─────────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(leftPad, nutY),
      Offset(leftPad + usableW, nutY),
      Paint()
        ..color       = baseFret == 1 ? Colors.white : Colors.white38
        ..strokeWidth = baseFret == 1 ? 5.0 : 1.5,
    );

    // ── Garis fret ───────────────────────────────────────────────────────
    final fretPaint = Paint()
      ..color       = Colors.white24
      ..strokeWidth = 1.0;
    for (int i = 1; i <= _frets; i++) {
      final dy = nutY + i * fretSp;
      canvas.drawLine(
        Offset(leftPad, dy),
        Offset(leftPad + usableW, dy),
        fretPaint,
      );
    }

    // ── Senar ────────────────────────────────────────────────────────────
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

    // ── Label nomor fret (kalau bukan open position) ─────────────────────
    if (baseFret > 1) {
      _drawText(
        canvas,
        '${baseFret}fr',
        Offset(2, nutY + fretSp * 0.5),
        const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        centerY: true,
      );
    }

    // ── Simbol X / O di atas senar ────────────────────────────────────────
    // Logika: jika string di-mute → X merah
    //         jika string open (tidak ada dot) → ○ putih transparan
    //         jika ada dot → tidak tampilkan simbol atas
    final stringsDotted = <int>{};
    for (final d in placedDots) {
      if (d.fret >= baseFret && d.fret < baseFret + _frets) {
        stringsDotted.add(d.string);
      }
    }

    for (int i = 0; i < _strings; i++) {
      final dx      = leftPad + i * strSp;
      final isMuted = mutedStrings[i];
      final hasDot  = stringsDotted.contains(i);

      if (isMuted) {
        _drawText(
          canvas, '✕',
          Offset(dx, nutY - 14),
          const TextStyle(
              color: Colors.redAccent,
              fontSize: 14,
              fontWeight: FontWeight.bold),
          centerX: true, centerY: true,
        );
      } else if (!hasDot) {
        // Open string
        _drawText(
          canvas, '○',
          Offset(dx, nutY - 14),
          TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
          centerX: true, centerY: true,
        );
      }
    }

    // ── Highlight tap-area (guide visual halus) ───────────────────────────
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..style = PaintingStyle.fill;
    for (int s = 0; s < _strings; s++) {
      for (int f = 0; f < _frets; f++) {
        final cx = leftPad + s * strSp;
        final cy = nutY + (f + 0.5) * fretSp;
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset(cx, cy),
              width: strSp * 0.9,
              height: fretSp * 0.9),
          gridPaint,
        );
      }
    }

    // ── Dots user ─────────────────────────────────────────────────────────
    int dotIdx = 0;
    for (final dot in placedDots) {
      // Hanya render dot yang ada di range fret yang ditampilkan
      final int row = dot.fret - baseFret;
      if (row < 0 || row >= _frets) {
        dotIdx++;
        continue;
      }

      final double dx = leftPad + dot.string * strSp;
      final double dy = nutY + (row + 0.5) * fretSp;

      Color color;
      if (reviewMode && reviewColors.containsKey(dot.string)) {
        color = reviewColors[dot.string]!;
      } else {
        color = _dotColor(dotIdx);
      }

      // Glow ring
      canvas.drawCircle(
        Offset(dx, dy), 16,
        Paint()
          ..color      = color.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Dot utama
      canvas.drawCircle(Offset(dx, dy), 13, Paint()..color = color);
      // Nomor jari (1-based dari urutan penempatan)
      _drawText(
        canvas, '${dotIdx + 1}',
        Offset(dx, dy),
        const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold),
        centerX: true, centerY: true,
      );

      dotIdx++;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset pos,
    TextStyle style, {
    bool centerX = false,
    bool centerY = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = centerX ? pos.dx - tp.width  / 2 : pos.dx;
    final dy = centerY ? pos.dy - tp.height / 2 : pos.dy;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_InteractivePainter old) =>
      old.placedDots   != placedDots   ||
      old.mutedStrings != mutedStrings ||
      old.baseFret     != baseFret     ||
      old.reviewMode   != reviewMode   ||
      old.reviewColors != reviewColors;
}
