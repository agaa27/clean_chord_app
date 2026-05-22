import 'package:flutter/material.dart';
import '../../../core/chord/models/finger_position.dart';
import '../../../core/chord/models/barre_info.dart';

// ─────────────────────────────────────────────────────────────────────────────
// InteractiveFretboardWidget
//
// RENDER-ONLY. Widget ini hanya:
//   • render strings, frets, dots, explicit barre
//   • panggil onTap(string, fret) saat user tap sel
//
// Widget TIDAK:
//   • detect barre otomatis
//   • normalize chord
//   • validate chord
//   • assign finger
//   • infer mini barre
// ─────────────────────────────────────────────────────────────────────────────

class InteractiveFretboardWidget extends StatelessWidget {
  final List<FingerPosition> placedDots;
  final List<bool> mutedStrings;
  final void Function(int string, int fret) onTap;
  final bool reviewMode;
  final Map<int, Color> reviewColors;
  final int baseFret;

  // Explicit barres — hanya render jika parent eksplisit kirim.
  // Default kosong → tidak ada barre yang dirender.
  final List<BarreInfo> barres;

  static const int _strings = 6;
  static const int _frets   = 5;

  const InteractiveFretboardWidget({
    super.key,
    required this.placedDots,
    required this.mutedStrings,
    required this.onTap,
    this.reviewMode  = false,
    this.reviewColors = const {},
    this.baseFret    = 1,
    this.barres      = const [],
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final stringSpacing = w / (_strings - 1);
        final fretSpacing   = h / _frets;

        return GestureDetector(
          onTapDown: reviewMode
              ? null
              : (details) {
                  final dx = details.localPosition.dx;
                  final dy = details.localPosition.dy;

                  final s = (dx / stringSpacing).round().clamp(0, _strings - 1);
                  final f = (dy / fretSpacing).floor().clamp(0, _frets - 1);

                  onTap(s, baseFret + f);
                },
          child: RepaintBoundary(
            child: CustomPaint(
              size: Size(w, h),
              painter: _FretboardPainter(
                placedDots:   placedDots,
                mutedStrings: mutedStrings,
                reviewColors: reviewColors,
                barres:       barres,
                baseFret:     baseFret,
                strings:      _strings,
                frets:        _frets,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────
class _FretboardPainter extends CustomPainter {
  final List<FingerPosition> placedDots;
  final List<bool> mutedStrings;
  final Map<int, Color> reviewColors;
  final List<BarreInfo> barres;
  final int baseFret;
  final int strings;
  final int frets;

  const _FretboardPainter({
    required this.placedDots,
    required this.mutedStrings,
    required this.reviewColors,
    required this.barres,
    required this.baseFret,
    required this.strings,
    required this.frets,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stringSpacing = size.width  / (strings - 1);
    final fretSpacing   = size.height / frets;

    _drawGrid(canvas, size, stringSpacing, fretSpacing);
    _drawBarres(canvas, stringSpacing, fretSpacing);
    _drawDots(canvas, stringSpacing, fretSpacing);
  }

  void _drawGrid(Canvas canvas, Size size, double ss, double fs) {
    // Fret lines
    final fretPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;

    for (int i = 0; i <= frets; i++) {
      final dy = i * fs;
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), fretPaint);
    }

    // Nut (fret 0 = atas) — tebal jika di posisi pertama
    if (baseFret == 1) {
      canvas.drawLine(
        Offset(0, 0),
        Offset(size.width, 0),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 4.0,
      );
    }

    // Strings
    for (int i = 0; i < strings; i++) {
      final dx = i * ss;
      canvas.drawLine(
        Offset(dx, 0),
        Offset(dx, size.height),
        Paint()
          ..color = Colors.white38
          ..strokeWidth = 1.0 + i * 0.18,
      );
    }

    // BaseFret label (pojok kiri atas jika > 1)
    if (baseFret > 1) {
      final tp = TextPainter(
        text: TextSpan(
          text: '${baseFret}fr',
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, const Offset(2, 2));
    }
  }

  void _drawBarres(Canvas canvas, double ss, double fs) {
    for (final b in barres) {
      final row = b.fret - baseFret;
      if (row < 0 || row >= frets) continue;

      final dy     = (row + 0.5) * fs;
      final xStart = b.startString * ss;
      final xEnd   = b.endString   * ss;

      // Saat review mode: warna barre ditentukan dari reviewColors string-nya.
      // Jika semua string barre hijau → hijau, ada satu merah → merah,
      // tidak ada reviewColors → warna default (merah jari).
      Color barreColor;
      if (reviewColors.isNotEmpty) {
        bool anyRed   = false;
        bool anyGreen = false;
        for (int s = b.startString; s <= b.endString; s++) {
          final c = reviewColors[s];
          if (c != null) {
            if (c == const Color(0xFF00E676)) anyGreen = true;
            else anyRed = true;
          }
        }
        if (anyRed) {
          barreColor = const Color(0xFFFF4C4C);
        } else if (anyGreen) {
          barreColor = const Color(0xFF00E676);
        } else {
          barreColor = const Color(0xFFFF4C4C);
        }
      } else {
        barreColor = const Color(0xFFFF4C4C);
      }

      // Glow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(xStart - 8, dy - 13),
            Offset(xEnd   + 8, dy + 13),
          ),
          const Radius.circular(12),
        ),
        Paint()
          ..color = barreColor.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Bar body
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(
            Offset(xStart - 7, dy - 11),
            Offset(xEnd   + 7, dy + 11),
          ),
          const Radius.circular(11),
        ),
        Paint()
          ..color = barreColor
          ..style = PaintingStyle.fill,
      );

      // Nomor jari
      final tp = TextPainter(
        text: TextSpan(
          text: '${b.finger}',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      tp.paint(
        canvas,
        Offset(
          (xStart + xEnd) / 2 - tp.width  / 2,
          dy                  - tp.height / 2,
        ),
      );
    }
  }

  void _drawDots(Canvas canvas, double ss, double fs) {
    // Kumpulkan posisi yang sudah di-cover barre → skip dot di posisi itu
    final barreCovered = <String>{};
    for (final b in barres) {
      final row = b.fret - baseFret;
      if (row < 0 || row >= frets) continue;
      for (int s = b.startString; s <= b.endString; s++) {
        barreCovered.add('${s}_${b.fret}');
      }
    }

    for (final dot in placedDots) {
      if (mutedStrings.length > dot.string && mutedStrings[dot.string]) continue;

      final key = '${dot.string}_${dot.fret}';
      if (barreCovered.contains(key)) continue;

      final row = dot.fret - baseFret;
      if (row < 0 || row >= frets) continue;

      final dx = dot.string * ss;
      final dy = (row + 0.5) * fs;

      // Warna dot: reviewColors jika ada, default blueAccent
      final Color dotColor = reviewColors.containsKey(dot.string)
          ? reviewColors[dot.string]!
          : Colors.blueAccent;

      // Glow
      canvas.drawCircle(
        Offset(dx, dy),
        18,
        Paint()
          ..color = dotColor.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Dot body
      canvas.drawCircle(Offset(dx, dy), 13, Paint()..color = dotColor);

      // Nomor jari (0 = tidak tampil)
      if (dot.finger > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${dot.finger}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        tp.paint(
          canvas,
          Offset(
            dx - tp.width  / 2,
            dy - tp.height / 2,
          ),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FretboardPainter old) {
    return old.placedDots   != placedDots   ||
           old.mutedStrings != mutedStrings  ||
           old.reviewColors != reviewColors  ||
           old.barres       != barres        ||
           old.baseFret     != baseFret;
  }
}
