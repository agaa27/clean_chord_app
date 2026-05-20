import 'package:flutter/material.dart';
import '../models/chord_shape_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Warna jari — satu sumber kebenaran untuk Painter dan Legend
// ─────────────────────────────────────────────────────────────────────────────
const _kFingerColors = <int, Color>{
  1: Color(0xFFFF4C4C), // Telunjuk   — merah
  2: Color(0xFF4C9EFF), // Tengah     — biru
  3: Color(0xFF00E676), // Manis      — hijau
  4: Color(0xFFFFAA00), // Kelingking — oranye
};

Color _fingerColor(int finger) {
  if (!_kFingerColors.containsKey(finger)) {
    return Colors.grey; // fallback aman (bukan cyan/pink lagi)
  }
  return _kFingerColors[finger]!;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget utama
// ─────────────────────────────────────────────────────────────────────────────
class ChordFretboardWidget extends StatefulWidget {
  final ChordShapeModel shape;
  final String chordName;

  const ChordFretboardWidget({
    super.key,
    required this.shape,
    this.chordName = '',
  });

  @override
  State<ChordFretboardWidget> createState() => _ChordFretboardWidgetState();
}

class _ChordFretboardWidgetState extends State<ChordFretboardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    // Jalankan setelah frame pertama — painter sudah punya size valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(ChordFretboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shape != widget.shape) {
      _controller.reset();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 280,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
            if (widget.chordName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  widget.chordName,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            _buildTopRow(),
            const SizedBox(height: 4),
            // Painter tidak menerima progress — dots selalu full size.
            // Efek animasi sepenuhnya di ScaleTransition di atas.
            SizedBox(
              height: 220,
              child: CustomPaint(
                size: const Size(double.infinity, 220),
                painter: _FretboardPainter(shape: widget.shape),
              ),
            ),
            const SizedBox(height: 10),
            _buildFingerLegend(),
          ],
        ),
      ),
    );
  }

  // ── Baris X / O ──────────────────────────────────────────────────────────
  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (i) {
        final fret = widget.shape.frets[i];
        String symbol = '';
        Color color = Colors.white70;
        if (fret == -1) {
          symbol = '✕';
          color = Colors.redAccent;
        } else if (fret == 0) {
          symbol = '○';
        }
        return SizedBox(
          width: 28,
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

  // ── Legend jari ──────────────────────────────────────────────────────────
  Widget _buildFingerLegend() {
    final usedFingers = <int>{};

    // Selalu masukkan jari 1 jika ada barre
    if (widget.shape.barreFret != null) usedFingers.add(1);

    for (int i = 0; i < widget.shape.fingers.length; i++) {
      final f = widget.shape.fingers[i];
      if (f <= 0 || widget.shape.frets[i] <= 0) continue;

      // Lewati jika sudah tercakup barre
      final isBarre =
          widget.shape.barreFret != null &&
          widget.shape.frets[i] == widget.shape.barreFret &&
          widget.shape.barreStartString != null &&
          widget.shape.barreEndString != null &&
          i >= widget.shape.barreStartString! &&
          i <= widget.shape.barreEndString!;

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
// Painter — tidak menerima progress, dots selalu full size
// ─────────────────────────────────────────────────────────────────────────────
class _FretboardPainter extends CustomPainter {
  final ChordShapeModel shape;

  const _FretboardPainter({required this.shape});

  static const int _strings = 6;
  static const int _frets = 5;

  @override
  void paint(Canvas canvas, Size size) {
    const double leftPad = 24;
    const double rightPad = 10;
    const double topPad = 8;
    const double bottomPad = 4;

    final double usableW = size.width - leftPad - rightPad;
    final double usableH = size.height - topPad - bottomPad;
    final double strSp = usableW / (_strings - 1);
    final double fretSp = usableH / _frets;
    final double nutY = topPad;
    final int startFret = shape.baseFret;

    // ── Nut ───────────────────────────────────────────────────────────────
    canvas.drawLine(
      Offset(leftPad, nutY),
      Offset(leftPad + usableW, nutY),
      Paint()
        ..color = startFret == 1 ? Colors.white : Colors.white38
        ..strokeWidth = startFret == 1 ? 5.0 : 1.5,
    );

    // ── Garis fret ────────────────────────────────────────────────────────
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

    // ── Senar (string 0 = low E, makin ke kanan makin tipis pitch) ────────
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

    // ── Label nomor fret (kalau bukan open position) ───────────────────────
    if (startFret > 1) {
      _drawText(
        canvas,
        '${startFret}fr',
        Offset(2, nutY + fretSp * 0.5),
        const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        centerY: true,
      );
    }

    // ── Barre bar ─────────────────────────────────────────────────────────
    if (shape.barreFret != null &&
        shape.barreStartString != null &&
        shape.barreEndString != null) {
      final int row = shape.barreFret! - startFret;
      if (row >= 0 && row < _frets) {
        final double dy = nutY + (row + 0.5) * fretSp;
        final double xStart = leftPad + shape.barreStartString! * strSp;
        final double xEnd = leftPad + shape.barreEndString! * strSp;
        const Color barreCol = Color(0xFFFF4C4C); // merah telunjuk

        // Glow
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

        // Bar utama
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

        // Angka "1" di tengah barre (telunjuk)
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

    // ── Dots jari ─────────────────────────────────────────────────────────
    for (int i = 0; i < _strings; i++) {
      final int absFret = shape.frets[i];
      if (absFret <= 0) continue;

      final int row = absFret - startFret;
      if (row < 0 || row >= _frets) continue;

      // Lewati string yang sudah dicakup barre
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

      // Glow ring
      canvas.drawCircle(
        Offset(dx, dy),
        16,
        Paint()
          ..color = color.withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );

      // Dot utama
      canvas.drawCircle(Offset(dx, dy), 13, Paint()..color = color);

      // Nomor jari
      if (safeFinger > 0) {
        _drawText(
          canvas,
          '$safeFinger',
          Offset(dx, dy),
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
