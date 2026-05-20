import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model posisi dot user
// string: 0=low E … 5=high e
// fret  : absolut (1-based, sesuai posisi di fretboard)
// ─────────────────────────────────────────────────────────────────────────────
class FingerPosition {
  final int string;
  final int fret;
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
// Warna dot — sama persis dengan chord_fretboard_widget.dart
// ─────────────────────────────────────────────────────────────────────────────
const _kFingerColors = <int, Color>{
  1: Color(0xFFFF4C4C),
  2: Color(0xFF4C9EFF),
  3: Color(0xFF00E676),
  4: Color(0xFFFFAA00),
};
Color _dotColor(int idx) => _kFingerColors[(idx % 4) + 1]!;

// ─────────────────────────────────────────────────────────────────────────────
// Widget fretboard interaktif
// Penampilan sepenuhnya mengikuti chord_fretboard_widget.dart (konsisten)
// ─────────────────────────────────────────────────────────────────────────────
class InteractiveFretboardWidget extends StatefulWidget {
  final List<FingerPosition> placedDots;
  final List<bool> mutedStrings;
  final void Function(int string, int fret) onTap;
  final void Function(int string) onToggleMute;
  final bool reviewMode;
  /// String index → warna review (hijau=benar, merah=salah)
  final Map<int, Color> reviewColors;
  final int baseFret;

  const InteractiveFretboardWidget({
    super.key,
    required this.placedDots,
    required this.mutedStrings,
    required this.onTap,
    required this.onToggleMute,
    this.reviewMode = false,
    this.reviewColors = const {},
    this.baseFret = 1,
  });

  @override
  State<InteractiveFretboardWidget> createState() =>
      _InteractiveFretboardWidgetState();
}

class _InteractiveFretboardWidgetState
    extends State<InteractiveFretboardWidget> {
  static const int _strings = 6;
  static const int _frets   = 5;

  // layout cache — diisi tiap build
  double _leftPad = 24;
  double _topPad  = 8;
  double _strSp   = 0;
  double _fretSp  = 0;

  void _recalc(BoxConstraints c) {
    _leftPad = 24;
    _topPad  = 8;
    _strSp   = (c.maxWidth  - _leftPad - 10) / (_strings - 1);
    _fretSp  = (c.maxHeight - _topPad  - 4)  / _frets;
  }

  ({int string, int fret})? _hitTest(Offset local) {
    final double x = local.dx - _leftPad;
    final double y = local.dy - _topPad;
    if (y < 0) return null;

    final int s = (x / _strSp).round().clamp(0, _strings - 1);
    final int row = y ~/ _fretSp; // 0-based row
    if (row < 0 || row >= _frets) return null;
    return (string: s, fret: row + widget.baseFret); // absolut
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      _recalc(constraints);
      return GestureDetector(
        onTapUp: (d) {
          final hit = _hitTest(d.localPosition);
          if (hit == null) return;
          HapticFeedback.selectionClick();
          widget.onTap(hit.string, hit.fret);
        },
        child: CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _InteractivePainter(
            placedDots:   widget.placedDots,
            mutedStrings: widget.mutedStrings,
            baseFret:     widget.baseFret,
            reviewMode:   widget.reviewMode,
            reviewColors: widget.reviewColors,
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter — tampilan sama persis dengan _FretboardPainter di pustaka_chord
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

    // ── Nut ──────────────────────────────────────────────────────────────
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

    // ── Label nomor fret (kalau bukan open position) ──────────────────────
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
    for (int i = 0; i < _strings; i++) {
      final dx       = leftPad + i * strSp;
      final hasDot   = placedDots.any((d) => d.string == i);
      final isMuted  = mutedStrings[i];

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
        _drawText(
          canvas, '○',
          Offset(dx, nutY - 14),
          TextStyle(
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 14),
          centerX: true, centerY: true,
        );
      }
    }

    // ── Highlight sel aktif (guide visual) ───────────────────────────────
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
    for (int idx = 0; idx < placedDots.length; idx++) {
      final dot = placedDots[idx];
      final int row = dot.fret - baseFret;
      if (row < 0 || row >= _frets) continue;

      final double dx = leftPad + dot.string * strSp;
      final double dy = nutY + (row + 0.5) * fretSp;

      // Warna: review mode pakai warna benar/salah, normal pakai warna jari
      Color color;
      if (reviewMode && reviewColors.containsKey(dot.string)) {
        color = reviewColors[dot.string]!;
      } else {
        color = _dotColor(idx);
      }

      // Glow ring — sama dengan fretboard_widget
      canvas.drawCircle(
        Offset(dx, dy), 16,
        Paint()
          ..color      = color.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Dot utama
      canvas.drawCircle(Offset(dx, dy), 13, Paint()..color = color);
      // Nomor urut
      _drawText(
        canvas, '${idx + 1}',
        Offset(dx, dy),
        const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold),
        centerX: true, centerY: true,
      );
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
