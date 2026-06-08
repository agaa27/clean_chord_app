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
// ChordFretboardWidget
//
// ARSITEKTUR LAYOUT — single source of truth untuk semua elemen:
//
//  Canvas dibagi menjadi zona-zona:
//
//  ┌──────────┬───────────────────────────────────┬──────────┐
//  │annotZone │          gridZone                 │ rightPad │
//  │          │  topRow: ○ / ✕                    │          │
//  │  "Nfr"   │──────────────────────────────────│          │
//  │          │  nut / frets / strings            │          │
//  │          │  barre + dots                     │          │
//  └──────────┴───────────────────────────────────┴──────────┘
//
//  KEY DESIGN PRINCIPLE (mengatasi overlap):
//  ─────────────────────────────────────────
//  annotZone lebar = _kAnnotW + _kAnnotGap + dotRMax
//  Ini menjamin string ke-0 (sx(0) = gridOriginX) selalu berjarak
//  minimal dotRMax dari tepi kanan annotZone, sehingga dot terkiri
//  TIDAK PERNAH memasuki annotZone secara visual, bahkan dengan glow.
//
//  SEMUA elemen pakai sx(i) / fy(row) yang identik → zero misalignment.
// ─────────────────────────────────────────────────────────────────────────────
class ChordFretboardWidget extends StatelessWidget {
  final ChordShapeModel shape;
  final String chordName;
  final bool compact;

  const ChordFretboardWidget({
    super.key,
    required this.shape,
    this.chordName = '',
    this.compact = false,
  });

  // Fixed dimensions untuk compact — tidak bergantung parent constraint sama sekali
  static const double _kCompactW = 100.0;
  static const double _kCompactFretH = 120.0;
  static const double _kCompactPad = 8.0;
  static const double _kCompactR = 12.0;

  @override
  Widget build(BuildContext context) =>
      compact ? _buildCompact() : _buildFull();

  Widget _buildCompact() {
    return Center(
      child: Container(
        width: _kCompactW,
        padding: EdgeInsets.all(_kCompactPad),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(_kCompactR),
          border: Border.all(
            color: Colors.cyanAccent.withOpacity(0.25),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chordName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  chordName,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            RepaintBoundary(
              child: SizedBox(
                width: _kCompactW - _kCompactPad * 2,
                height: _kCompactFretH,
                child: CustomPaint(painter: _FretboardPainter(shape: shape)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = (constraints.maxWidth - 32).clamp(0.0, 300.0);
        return Center(
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
                RepaintBoundary(
                  child: SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _FretboardPainter(shape: shape),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildFingerLegend(),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Legend jari ──────────────────────────────────────────────────────────
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
// _FretboardPainter
//
// ══════════════════════════════════════════════════════════════════════════════
// GEOMETRY SYSTEM — SINGLE SOURCE OF TRUTH
// ══════════════════════════════════════════════════════════════════════════════
//
//
//    gridOriginX = _kAnnotW + _kAnnotGap + dotRMax
//    ──────────────────────────────────────────────
//    Ini adalah kunci anti-overlap:
//    • _kAnnotW   = lebar teks label ("10fr" max ~28px)
//    • _kAnnotGap = breathing room antara label dan string 0
//    • dotRMax    = radius maksimum dot yang mungkin digambar
//    Dengan formula ini, tepi kiri dot pada string 0 = sx(0) - dotRMax
//    = gridOriginX - dotRMax = _kAnnotW + _kAnnotGap
//    → selalu ada gap _kAnnotGap antara label dan tepi dot. ✓
//
//
//
//  HELPERS:
//    sx(i)   = gridOriginX + i × strSp     → X tengah string ke-i
//    fy(row) = gridOriginY + (row+0.5)×fretSp → Y tengah fret row
//
//  Semua elemen — nut, fret lines, string lines, barre, dots,
//  open/mute indicators, base fret label — menggunakan sx/fy yang sama.
//  Tidak ada offset ad-hoc per elemen atau per chord.
// ─────────────────────────────────────────────────────────────────────────────
class _FretboardPainter extends CustomPainter {
  final ChordShapeModel shape;

  const _FretboardPainter({required this.shape});

  // ── Konstanta struktur ──────────────────────────────────────────────────
  static const int _kStrings = 6;
  static const int _kFrets = 5;

  // ── Konstanta annotZone ─────────────────────────────────────────────────
  // _kAnnotW: lebar teks label basefret (e.g. "10fr" ≈ 28px @ fontSize 11.5)
  // Dibuat cukup untuk worst-case 2-digit fret number.
  static const double _kAnnotW = 30.0;

  // _kAnnotGap: jarak minimum antara tepi kanan label dan tepi kiri dot string-0.
  // Ini adalah optical safety margin — semakin besar semakin aman.
  static const double _kAnnotGap = 8.0;

  // _kDotRMax: radius maksimum dot. Dipakai untuk menghitung gridOriginX.
  // HARUS KONSISTEN dengan perhitungan dotR di bawah agar anti-overlap valid.
  // dotR = (strSp * 0.42).clamp(7.0, _kDotRMax)
  static const double _kDotRMax = 14.0;

  // _kLeftPadOpen: padding kiri minimal saat tidak ada annotZone (baseFret == 1).
  // Memberi sedikit breathing room agar fretboard tidak menempel tepi kiri card.
  static const double _kLeftPadOpen = 8.0;

  // ── Konstanta layout vertikal ───────────────────────────────────────────
  // Rasio terhadap tinggi canvas. Pakai const agar mudah di-tune.
  static const double _kTopPadR = 0.025; // breathing room atas
  static const double _kTopRowR = 0.085; // zona ○/✕ — lebih compact dari 0.10
  static const double _kBottomPadR =
      0.09; // breathing room bawah — min dotR aman

  // ── Konstanta visual ────────────────────────────────────────────────────
  static const double _kLabelFontSz = 11.5;
  static const double _kOpenSymbolSz = 12.5; // ukuran ○/✕
  static const double _kBarreFontSz = 11.5;

  // Nut: tebal hanya saat fret 1 (open position), tipis saat barre position.
  static const double _kNutThickOpen = 3.5; // lebih tipis dari 5.0 sebelumnya
  static const double _kNutThickBarre = 1.5;

  // String thickness: bass (i=0, kiri) lebih tebal dari treble (i=5, kanan).
  // Urutan visual di diagram: string 0 = low E (bass), string 5 = high e (treble).
  // strokeWidth MENURUN seiring naiknya i.
  static double _stringThickness(int i) {
    // Bass (i=0): ~1.8, Treble (i=5): ~0.8
    // Linear: 1.8 - i * 0.2  → [1.8, 1.6, 1.4, 1.2, 1.0, 0.8]
    return 1.8 - i * 0.20;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // ── 1. Zona horizontal ─────────────────────────────────────────────────
    //
    //   baseFret == 1  →  tidak ada label → annotZone = 0
    //                     gridOriginX = _kLeftPadOpen (kecil, simetris)
    //
    //   baseFret > 1   →  ada label "Nfr" → annotZone aktif
    //                     gridOriginX = _kAnnotW + _kAnnotGap + _kDotRMax
    //                     gap antara label & tepi kiri dot ≥ _kAnnotGap  ✓
    //
    //   rightPad selalu = _kLeftPadOpen → simetris di sisi kanan.
    //   Open chord: kiri = kanan = _kLeftPadOpen → perfectly centered.
    //   Barre chord: kiri lebih besar (annotZone) → grid geser kanan secukupnya.

    final bool hasAnnot = shape.baseFret > 1;
    final double gridOriginX = hasAnnot
        ? _kAnnotW + _kAnnotGap + _kDotRMax
        : _kLeftPadOpen;
    const double rightPad = _kLeftPadOpen;
    final double gridW = size.width - gridOriginX - rightPad;

    // Pastikan gridW valid (canvas terlalu kecil → skip paint)
    if (gridW <= 0) return;

    // ── 2. Zona vertikal ───────────────────────────────────────────────────
    final double topPad = size.height * _kTopPadR;
    final double topRowH = size.height * _kTopRowR;
    final double bottomPad = (size.height * _kBottomPadR).clamp(
      _kDotRMax + 2.0,
      double.infinity,
    );
    final double gridOriginY = topPad + topRowH;
    final double gridH = size.height - gridOriginY - bottomPad;

    if (gridH <= 0) return;

    // ── 3. Derived geometry ────────────────────────────────────────────────
    final double strSp = gridW / (_kStrings - 1);
    final double fretSp = gridH / _kFrets;
    final int startFret = shape.baseFret;

    // dotR: radius dot jari.
    // Dibatasi _kDotRMax agar konsisten dengan asumsi gridOriginX.
    // Formula: 42% dari string spacing, clamped [7, _kDotRMax].
    final double dotR = (strSp * 0.42).clamp(7.0, _kDotRMax);
    final double dotFontSz = (dotR * 0.88).clamp(8.5, 12.5);

    // Glow radius untuk dot: lebih kecil dari sebelumnya agar tidak melebar jauh.
    final double glowR = dotR + 2.5;

    // ── 4. Helpers koordinat — SATU SOURCE OF TRUTH ────────────────────────
    // Semua elemen wajib menggunakan sx() dan fy() ini.
    // Tidak ada hardcoded X/Y di luar dua fungsi ini.
    double sx(int i) => gridOriginX + i * strSp;
    double fy(int row) => gridOriginY + (row + 0.5) * fretSp;

    // ── 5. Top row: simbol ○ / ✕ ──────────────────────────────────────────
    // Y-center di antara topPad dan gridOriginY, dengan optical offset kecil
    // agar simbol tidak terlalu mepet ke nut.
    // topRowMidY = topPad + topRowH * 0.55 → sedikit ke bawah dari center,
    // memberi lebih banyak ruang antara simbol dan tepi atas canvas.
    final double topRowMidY = topPad + topRowH * 0.55;

    for (int i = 0; i < _kStrings; i++) {
      final int fret = shape.frets[i];
      if (fret != 0 && fret != -1) continue;

      final String symbol = fret == 0 ? '○' : '✕';
      final Color color = fret == 0 ? Colors.white70 : Colors.redAccent;

      _drawText(
        canvas,
        symbol,
        Offset(sx(i), topRowMidY),
        TextStyle(
          color: color,
          fontSize: _kOpenSymbolSz,
          fontWeight: FontWeight.w600,
        ),
        centerX: true,
        centerY: true,
      );
    }

    // ── 6. Nut ─────────────────────────────────────────────────────────────
    // Saat open position (fret 1): nut tebal & putih terang.
    // Saat barre position: nut tipis & redup (hanya penanda tepi grid).
    final bool isOpenPosition = startFret == 1;
    canvas.drawLine(
      Offset(gridOriginX, gridOriginY),
      Offset(gridOriginX + gridW, gridOriginY),
      Paint()
        ..color = isOpenPosition ? Colors.white : Colors.white30
        ..strokeWidth = isOpenPosition ? _kNutThickOpen : _kNutThickBarre
        ..strokeCap = StrokeCap.butt,
    );

    // ── 7. Fret lines ──────────────────────────────────────────────────────
    final Paint fretPaint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 0.8;
    for (int i = 1; i <= _kFrets; i++) {
      final double dy = gridOriginY + i * fretSp;
      canvas.drawLine(
        Offset(gridOriginX, dy),
        Offset(gridOriginX + gridW, dy),
        fretPaint,
      );
    }

    // ── 8. String lines ────────────────────────────────────────────────────
    // Urutan: i=0 = bass/low-E (kiri visual) → tebal.
    //         i=5 = treble/high-e (kanan visual) → tipis.
    for (int i = 0; i < _kStrings; i++) {
      final double stringTop = gridOriginY;
      final double stringBottom = gridOriginY + _kFrets * fretSp;

      canvas.drawLine(
        Offset(sx(i), stringTop),
        Offset(sx(i), stringBottom),
        Paint()
          ..color = Colors.white38
          ..strokeWidth = _stringThickness(i)
          ..strokeCap = StrokeCap.butt,
      );
    }

    // ── 9. Barre ───────────────────────────────────────────────────────────
    if (shape.barreFret != null &&
        shape.barreStartString != null &&
        shape.barreEndString != null) {
      final int row = shape.barreFret! - startFret;
      if (row >= 0 && row < _kFrets) {
        final double dy = fy(row);
        final double xStart = sx(shape.barreStartString!);
        final double xEnd = sx(shape.barreEndString!);

        // Barre height: proporsi fretSp agar tidak overflow ke fret berikutnya.
        final double barreH = (fretSp * 0.52).clamp(10.0, 22.0);
        final double barreR = barreH * 0.5;

        const Color col = Color(0xFFFF4C4C);

        // Glow layer
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset((xStart + xEnd) / 2, dy),
              width: (xEnd - xStart) + barreH + 4,
              height: barreH + 6,
            ),
            Radius.circular(barreR + 2),
          ),
          Paint()
            ..color = col.withOpacity(0.20)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );

        // Body layer
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset((xStart + xEnd) / 2, dy),
              width: (xEnd - xStart) + barreH,
              height: barreH,
            ),
            Radius.circular(barreR),
          ),
          Paint()
            ..color = col.withOpacity(0.92)
            ..style = PaintingStyle.fill,
        );

        // Label "1"
        _drawText(
          canvas,
          '1',
          Offset((xStart + xEnd) / 2, dy),
          const TextStyle(
            color: Colors.black,
            fontSize: _kBarreFontSz,
            fontWeight: FontWeight.bold,
          ),
          centerX: true,
          centerY: true,
        );
      }
    }

    // ── 10. Finger dots ────────────────────────────────────────────────────
    for (int i = 0; i < _kStrings; i++) {
      final int absFret = shape.frets[i];
      if (absFret <= 0) continue;

      final int row = absFret - startFret;
      if (row < 0 || row >= _kFrets) continue;

      // Skip string yang sudah dicakup barre
      if (shape.barreFret != null &&
          absFret == shape.barreFret &&
          shape.barreStartString != null &&
          shape.barreEndString != null &&
          i >= shape.barreStartString! &&
          i <= shape.barreEndString!) {
        continue;
      }

      final int finger = shape.fingers[i];
      final int safeF = (absFret > 0 && finger == 0) ? 1 : finger;
      final Color color = _fingerColor(safeF);
      final double dx = sx(i);
      final double dy = fy(row);

      // Glow — radius lebih ketat dari sebelumnya
      canvas.drawCircle(
        Offset(dx, dy),
        glowR,
        Paint()
          ..color = color.withOpacity(0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );

      // Body dot
      canvas.drawCircle(Offset(dx, dy), dotR, Paint()..color = color);

      // Nomor jari
      if (safeF > 0) {
        _drawText(
          canvas,
          '$safeF',
          Offset(dx, dy),
          TextStyle(
            color: Colors.black,
            fontSize: dotFontSz,
            fontWeight: FontWeight.bold,
          ),
          centerX: true,
          centerY: true,
        );
      }
    }

    // ── 11. Base fret label ────────────────────────────────────────────────
    // Hanya digambar saat baseFret > 1 (hasAnnot == true).
    // Saat hasAnnot, gridOriginX = _kAnnotW + _kAnnotGap + _kDotRMax,
    // sehingga label yang right-align di _kAnnotW selalu berjarak
    // minimal _kAnnotGap dari tepi kiri dot string-0. ✓
    if (hasAnnot) {
      // Vertikal: rata tengah ke fret row pertama (row 0), sejajar dengan
      // dot di fret pertama secara optis. Ini lebih intuitif dari
      // sekadar gridOriginY + 0.5*fretSp.
      final double labelY = fy(0);

      final tp = TextPainter(
        text: TextSpan(
          text: '${startFret}fr',
          style: const TextStyle(
            color: Colors.white60,
            fontSize: _kLabelFontSz,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Right-align di dalam _kAnnotW dengan sedikit optical padding
      final double lx = (_kAnnotW - tp.width).clamp(0.0, double.infinity);
      final double ly = labelY - tp.height / 2;
      tp.paint(canvas, Offset(lx, ly));
    }
  }

  // ── Helper teks ────────────────────────────────────────────────────────────
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
    tp.paint(
      canvas,
      Offset(
        centerX ? pos.dx - tp.width / 2 : pos.dx,
        centerY ? pos.dy - tp.height / 2 : pos.dy,
      ),
    );
  }

  @override
  bool shouldRepaint(_FretboardPainter old) => old.shape != shape;
}
