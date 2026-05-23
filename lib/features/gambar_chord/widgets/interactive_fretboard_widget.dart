import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/chord/models/finger_position.dart';
import '../../../core/chord/models/barre_info.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InteractiveFretboardWidget
//
// Painter-nya menggunakan sistem koordinat yang IDENTIK dengan
// ChordFretboardWidget (pustaka_chord):
//   leftPad=24, rightPad=10, topPad=8, bottomPad=4
//   stringSpacing = usableW / 5
//   fretSpacing   = usableH / 5
//   dot di (leftPad + string*strSp,  nutY + (row+0.5)*fretSp)
//
// Hit-test onTapDown juga memakai padding yang sama sehingga tap
// selalu tepat sesuai visual.
// ─────────────────────────────────────────────────────────────────────────────

// Warna jari — identik dengan ChordFretboardWidget
const _kFingerColors = <int, Color>{
  1: Color(0xFFFF4C4C),
  2: Color(0xFF4C9EFF),
  3: Color(0xFF00E676),
  4: Color(0xFFFFAA00),
};
Color _fingerColor(int f) => _kFingerColors[f] ?? Colors.blueAccent;

class InteractiveFretboardWidget extends StatelessWidget {
  final List<FingerPosition> placedDots;
  final List<bool>           mutedStrings;
  final void Function(int string, int fret) onTap;
  final bool                 reviewMode;
  final Map<int, Color>      reviewColors;
  final int                  baseFret;
  final List<BarreInfo>      barres;

  static const int    _strings    = 6;
  static const int    _frets      = 5;
  // Padding IDENTIK dengan ChordFretboardWidget._FretboardPainter
  static const double _leftPad    = 24.0;
  static const double _rightPad   = 10.0;
  static const double _topPad     =  8.0;
  static const double _bottomPad  =  4.0;

  const InteractiveFretboardWidget({
    super.key,
    required this.placedDots,
    required this.mutedStrings,
    required this.onTap,
    this.reviewMode   = false,
    this.reviewColors = const {},
    this.baseFret     = 1,
    this.barres       = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      // Koordinat identik dengan painter
      final usableW   = w - _leftPad - _rightPad;
      final usableH   = h - _topPad  - _bottomPad;
      final strSp     = usableW / (_strings - 1);
      final fretSp    = usableH / _frets;

      return GestureDetector(
        onTapDown: reviewMode
            ? null
            : (d) {
                final dx = d.localPosition.dx - _leftPad;
                final dy = d.localPosition.dy - _topPad;

                // string: cari yang paling dekat (round)
                final s = (dx / strSp).round().clamp(0, _strings - 1);
                // fret row: floor, clamp agar tidak out-of-bound
                final row = (dy / fretSp).floor().clamp(0, _frets - 1);

                HapticFeedback.selectionClick();
                onTap(s, baseFret + row);
              },
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size(w, h),
            painter: _InteractivePainter(
              placedDots:   placedDots,
              mutedStrings: mutedStrings,
              reviewColors: reviewColors,
              barres:       barres,
              baseFret:     baseFret,
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter — koordinat identik dengan ChordFretboardWidget._FretboardPainter
// ─────────────────────────────────────────────────────────────────────────────
class _InteractivePainter extends CustomPainter {
  final List<FingerPosition> placedDots;
  final List<bool>           mutedStrings;
  final Map<int, Color>      reviewColors;
  final List<BarreInfo>      barres;
  final int                  baseFret;

  static const int    _strings   = 6;
  static const int    _frets     = 5;
  static const double _leftPad   = 24.0;
  static const double _rightPad  = 10.0;
  static const double _topPad    =  8.0;
  static const double _bottomPad =  4.0;

  const _InteractivePainter({
    required this.placedDots,
    required this.mutedStrings,
    required this.reviewColors,
    required this.barres,
    required this.baseFret,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final usableW = size.width  - _leftPad - _rightPad;
    final usableH = size.height - _topPad  - _bottomPad;
    final strSp   = usableW / (_strings - 1);
    final fretSp  = usableH / _frets;
    final nutY    = _topPad;

    _drawGrid(canvas, size, strSp, fretSp, nutY, usableW);
    _drawBarres(canvas, strSp, fretSp, nutY);
    _drawDots(canvas, strSp, fretSp, nutY);
  }

  // ── Grid — identik dengan ChordFretboardWidget ──────────────────────────
  void _drawGrid(Canvas canvas, Size size, double strSp, double fretSp,
      double nutY, double usableW) {
    // Nut
    canvas.drawLine(
      Offset(_leftPad, nutY),
      Offset(_leftPad + usableW, nutY),
      Paint()
        ..color       = baseFret == 1 ? Colors.white : Colors.white38
        ..strokeWidth = baseFret == 1 ? 5.0 : 1.5,
    );

    // Fret lines
    final fretPaint = Paint()
      ..color       = Colors.white24
      ..strokeWidth = 1.0;
    for (int i = 1; i <= _frets; i++) {
      final dy = nutY + i * fretSp;
      canvas.drawLine(
        Offset(_leftPad, dy),
        Offset(_leftPad + usableW, dy),
        fretPaint,
      );
    }

    // Strings
    for (int i = 0; i < _strings; i++) {
      final dx = _leftPad + i * strSp;
      canvas.drawLine(
        Offset(dx, nutY),
        Offset(dx, nutY + _frets * fretSp),
        Paint()
          ..color       = Colors.white38
          ..strokeWidth = 1.0 + i * 0.22,
      );
    }

    // BaseFret label
    if (baseFret > 1) {
      _text(
        canvas,
        '${baseFret}fr',
        Offset(2, nutY + fretSp * 0.5),
        const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        cy: true,
      );
    }
  }

  // ── Barre bars ───────────────────────────────────────────────────────────
  void _drawBarres(Canvas canvas, double strSp, double fretSp, double nutY) {
    for (final b in barres) {
      final row = b.fret - baseFret;
      if (row < 0 || row >= _frets) continue;

      final dy     = nutY + (row + 0.5) * fretSp;
      final xStart = _leftPad + b.startString * strSp;
      final xEnd   = _leftPad + b.endString   * strSp;

      // Warna: review → cek reviewColors, default → merah (jari 1)
      Color barreColor = _fingerColor(1); // merah = jari 1
      if (reviewColors.isNotEmpty) {
        bool anyRed = false, anyGreen = false;
        for (int s = b.startString; s <= b.endString; s++) {
          final c = reviewColors[s];
          if (c == const Color(0xFF00E676)) anyGreen = true;
          else if (c != null) anyRed = true;
        }
        barreColor = anyRed
            ? const Color(0xFFFF4C4C)
            : anyGreen
                ? const Color(0xFF00E676)
                : _fingerColor(1);
      }

      // Glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(Offset(xStart - 8, dy - 13), Offset(xEnd + 8, dy + 13)),
          const Radius.circular(12),
        ),
        Paint()
          ..color      = barreColor.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(Offset(xStart - 7, dy - 11), Offset(xEnd + 7, dy + 11)),
          const Radius.circular(11),
        ),
        Paint()
          ..color = barreColor.withValues(alpha: 0.9)
          ..style = PaintingStyle.fill,
      );
      // Label jari
      _text(canvas, '${b.finger}',
          Offset((xStart + xEnd) / 2, dy),
          const TextStyle(
              color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
          cx: true, cy: true);
    }
  }

  // ── Dots individual ──────────────────────────────────────────────────────
  void _drawDots(Canvas canvas, double strSp, double fretSp, double nutY) {
    // String yang di-cover barre → skip dot di fret barre
    final barreCovered = <String>{};
    for (final b in barres) {
      for (int s = b.startString; s <= b.endString; s++) {
        barreCovered.add('${s}_${b.fret}');
      }
    }

    for (final dot in placedDots) {
      if (dot.string < mutedStrings.length && mutedStrings[dot.string]) continue;
      if (barreCovered.contains('${dot.string}_${dot.fret}')) continue;

      final row = dot.fret - baseFret;
      if (row < 0 || row >= _frets) continue;

      final dx = _leftPad + dot.string * strSp;
      final dy = nutY + (row + 0.5) * fretSp;

      // Warna: reviewColors jika ada, atau warna jari dari _kFingerColors
      final Color color = reviewColors.containsKey(dot.string)
          ? reviewColors[dot.string]!
          : _fingerColor(dot.finger > 0 ? dot.finger : 2);

      // Glow
      canvas.drawCircle(Offset(dx, dy), 16,
          Paint()
            ..color      = color.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
      // Dot
      canvas.drawCircle(Offset(dx, dy), 13, Paint()..color = color);
      // Nomor jari
      if (dot.finger > 0) {
        _text(canvas, '${dot.finger}', Offset(dx, dy),
            const TextStyle(
                color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
            cx: true, cy: true);
      }
    }
  }

  // ── Helper teks ──────────────────────────────────────────────────────────
  void _text(Canvas canvas, String t, Offset pos, TextStyle style,
      {bool cx = false, bool cy = false}) {
    final tp = TextPainter(
        text: TextSpan(text: t, style: style),
        textDirection: TextDirection.ltr)
      ..layout();
    final dx = cx ? pos.dx - tp.width  / 2 : pos.dx;
    final dy = cy ? pos.dy - tp.height / 2 : pos.dy;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _InteractivePainter old) =>
      old.placedDots   != placedDots   ||
      old.mutedStrings != mutedStrings  ||
      old.reviewColors != reviewColors  ||
      old.barres       != barres        ||
      old.baseFret     != baseFret;
}