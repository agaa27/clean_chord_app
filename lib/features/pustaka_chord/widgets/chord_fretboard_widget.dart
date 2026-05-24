import 'package:flutter/material.dart';
import '../models/chord_shape_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Warna jari
// ─────────────────────────────────────────────────────────────────────────────
const _kFingerColors = <int, Color>{
  1: Color(0xFFFF4C4C),
  2: Color(0xFF4C9EFF),
  3: Color(0xFF00E676),
  4: Color(0xFFFFAA00),
};

Color _fingerColor(int finger) => _kFingerColors[finger] ?? Colors.grey;

// ─────────────────────────────────────────────────────────────────────────────
// Widget utama
//
// FIX OVERFLOW:
//   • LayoutBuilder dipakai untuk mendapatkan lebar tersedia → Container
//     tidak pernah melebihi lebar layar.
//   • Lebar widget dibatasi: min(tersedia - 32, 300) sehingga responsif di
//     layar sempit maupun lebar.
//   • Tinggi CustomPaint dihitung dari lebar aktual via AspectRatio (4:5)
//     sehingga tidak overflow vertikal di layar kecil.
//   • Column dibungkus SingleChildScrollView → bila konten legend panjang
//     tetap scrollable, tidak overflow.
//   • RepaintBoundary tetap dipertahankan untuk efisiensi repaint.
// ─────────────────────────────────────────────────────────────────────────────
class ChordFretboardWidget extends StatelessWidget {
  final ChordShapeModel shape;
  final String chordName;

  const ChordFretboardWidget({
    super.key,
    required this.shape,
    this.chordName = '',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar widget: maks 300, min sesuai ruang tersedia dikurangi margin
        final double cardWidth =
            (constraints.maxWidth - 32).clamp(0.0, 300.0);

        return Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Container(
              width: cardWidth,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.08),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (chordName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        chordName,
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  _buildTopRow(cardWidth),
                  const SizedBox(height: 4),
                  // Tinggi fretboard diturunkan dari lebar via AspectRatio (4:5)
                  // → tidak pernah overflow vertikal
                  RepaintBoundary(
                    child: AspectRatio(
                      aspectRatio: 4 / 5,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: _FretboardPainter(shape: shape),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildFingerLegend(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Baris X / O ────────────────────────────────────────────────────────
  Widget _buildTopRow(double cardWidth) {
    // Lebar tiap kolom proporsional terhadap lebar card aktual
    final double colW = ((cardWidth - 32) / 6).clamp(20.0, 36.0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) {
        final fret = shape.frets[i];
        String symbol = '';
        Color color = Colors.white70;
        if (fret == -1) {
          symbol = '✕';
          color = Colors.redAccent;
        } else if (fret == 0) {
          symbol = '○';
        }
        return SizedBox(
          width: colW,
          child: Center(
            child: symbol.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    symbol,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  // ── Legend jari ────────────────────────────────────────────────────────
  Widget _buildFingerLegend() {
    final usedFingers = <int>{};

    if (shape.barreFret != null) usedFingers.add(1);

    for (int i = 0; i < shape.fingers.length; i++) {
      final f = shape.fingers[i];
      if (f <= 0 || shape.frets[i] <= 0) continue;

      final isBarre =
          shape.barreFret != null &&
          shape.frets[i] == shape.barreFret &&
          shape.barreStartString != null &&
          shape.barreEndString != null &&
          i >= shape.barreStartString! &&
          i <= shape.barreEndString!;

      if (!isBarre) usedFingers.add(f);
    }

    if (usedFingers.isEmpty) return const SizedBox.shrink();

    const labels = <int, String>{
      1: 'Telunjuk',
      2: 'Tengah',
      3: 'Manis',
      4: 'Kelingking',
    };

    final sorted = usedFingers.toList()..sort();

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: sorted.map((f) {
        final color = _fingerColor(f);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.5), blurRadius: 6),
                ],
              ),
              child: Center(
                child: Text(
                  '$f',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Text(
              labels[f] ?? '',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter
// ─────────────────────────────────────────────────────────────────────────────
class _FretboardPainter extends CustomPainter {
  final ChordShapeModel shape;

  const _FretboardPainter({required this.shape});

  static const int _strings = 6;
  static const int _frets = 5;

  @override
  void paint(Canvas canvas, Size size) {
    // Padding dihitung relatif terhadap ukuran aktual → tidak hardcoded
    final double leftPad = size.width * 0.10;
    final double rightPad = size.width * 0.04;
    final double topPad = size.height * 0.04;
    final double bottomPad = size.height * 0.02;

    final double usableW = size.width - leftPad - rightPad;
    final double usableH = size.height - topPad - bottomPad;
    final double strSp = usableW / (_strings - 1);
    final double fretSp = usableH / _frets;
    final double nutY = topPad;
    final int startFret = shape.baseFret;

    // Dot radius proporsional terhadap string spacing
    final double dotRadius = (strSp * 0.45).clamp(8.0, 15.0);
    final double dotFontSize = (dotRadius * 0.9).clamp(9.0, 13.0);

    // ── Nut / top fret ───────────────────────────────────────────────────
    canvas.drawLine(
      Offset(leftPad, nutY),
      Offset(leftPad + usableW, nutY),
      Paint()
        ..color = startFret == 1 ? Colors.white : Colors.white38
        ..strokeWidth = startFret == 1 ? 5.0 : 1.5,
    );

    // ── Fret lines ───────────────────────────────────────────────────────
    final fretPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1.0;
    for (int i = 1; i <= _frets; i++) {
      final dy = nutY + i * fretSp;
      canvas.drawLine(
        Offset(leftPad, dy),
        Offset(leftPad + usableW, dy),
        fretPaint,
      );
    }

    // ── String lines ─────────────────────────────────────────────────────
    for (int i = 0; i < _strings; i++) {
      final dx = leftPad + i * strSp;
      canvas.drawLine(
        Offset(dx, nutY),
        Offset(dx, nutY + _frets * fretSp),
        Paint()
          ..color = Colors.white38
          ..strokeWidth = 1.0 + i * 0.22,
      );
    }

    // ── Base fret label ──────────────────────────────────────────────────
    if (startFret > 1) {
      _drawText(
        canvas,
        '${startFret}fr',
        Offset(2, nutY + fretSp * 0.5),
        TextStyle(
          color: Colors.white70,
          fontSize: dotFontSize * 0.9,
          fontWeight: FontWeight.w600,
        ),
        centerY: true,
      );
    }

    // ── Barre ────────────────────────────────────────────────────────────
    if (shape.barreFret != null &&
        shape.barreStartString != null &&
        shape.barreEndString != null) {
      final int row = shape.barreFret! - startFret;
      if (row >= 0 && row < _frets) {
        final double dy = nutY + (row + 0.5) * fretSp;
        final double xStart = leftPad + shape.barreStartString! * strSp;
        final double xEnd = leftPad + shape.barreEndString! * strSp;
        const Color barreCol = Color(0xFFFF4C4C);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(xStart - 8, dy - 13),
              Offset(xEnd + 8, dy + 13),
            ),
            const Radius.circular(12),
          ),
          Paint()
            ..color = barreCol.withOpacity(0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        );

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(xStart - 7, dy - 11),
              Offset(xEnd + 7, dy + 11),
            ),
            const Radius.circular(11),
          ),
          Paint()
            ..color = barreCol.withOpacity(0.9)
            ..style = PaintingStyle.fill,
        );

        _drawText(
          canvas,
          '1',
          Offset((xStart + xEnd) / 2, dy),
          const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          centerX: true,
          centerY: true,
        );
      }
    }

    // ── Finger dots ──────────────────────────────────────────────────────
    for (int i = 0; i < _strings; i++) {
      final int absFret = shape.frets[i];
      if (absFret <= 0) continue;

      final int row = absFret - startFret;
      if (row < 0 || row >= _frets) continue;

      if (shape.barreFret != null &&
          absFret == shape.barreFret &&
          shape.barreStartString != null &&
          shape.barreEndString != null &&
          i >= shape.barreStartString! &&
          i <= shape.barreEndString!) {
        continue;
      }

      final int finger = shape.fingers[i];
      final int safeFinger = (absFret > 0 && finger == 0) ? 1 : finger;
      final Color color = _fingerColor(safeFinger);
      final double dx = leftPad + i * strSp;
      final double dy = nutY + (row + 0.5) * fretSp;

      // Glow
      canvas.drawCircle(
        Offset(dx, dy),
        dotRadius + 3,
        Paint()
          ..color = color.withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Dot
      canvas.drawCircle(Offset(dx, dy), dotRadius, Paint()..color = color);

      if (safeFinger > 0) {
        _drawText(
          canvas,
          '$safeFinger',
          Offset(dx, dy),
          TextStyle(
            color: Colors.black,
            fontSize: dotFontSize,
            fontWeight: FontWeight.bold,
          ),
          centerX: true,
          centerY: true,
        );
      }
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
    final dx = centerX ? pos.dx - tp.width / 2 : pos.dx;
    final dy = centerY ? pos.dy - tp.height / 2 : pos.dy;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(_FretboardPainter old) => old.shape != shape;
}
