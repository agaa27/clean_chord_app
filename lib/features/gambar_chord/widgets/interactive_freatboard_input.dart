import 'package:flutter/material.dart';

// ── 1. PEMBUATAN MODEL LOKAL AGAR AMAN DARI ERROR IMPORT ──
// Daripada mengambil dari pustaka_chord yang jalurnya rentan salah,
// kita buat class representasi posisi fret langsung di sini.
class FretPosition {
  final int string; // Senar 1-6
  final int fret;   // Fret 0-5

  const FretPosition({required this.string, required this.fret});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FretPosition &&
          runtimeType == other.runtimeType &&
          string == other.string &&
          fret == other.fret;

  @override
  int get hashCode => string.hashCode ^ fret.hashCode;
}

class InteractiveFretboardInput extends StatelessWidget {
  /// Titik-titik yang saat ini ditekan oleh user
  final List<FretPosition> userInput;
  /// Callback saat user menekan sebuah posisi
  final Function(FretPosition) onTap;
  final Color accentColor;

  const InteractiveFretboardInput({
    super.key,
    required this.userInput,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.6, // Vertikal
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF101825),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: accentColor.withAlpha((0.1 * 255).round()), // Mengganti withOpacity yang deprecated
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final double height = constraints.maxHeight;
            
            const int totalFrets = 5; // Tampilkan 5 fret
            final double stringSpacing = width / 7;
            final double fretSpacing = height / (totalFrets + 1);

            return Stack(
              children: [
                // 1. Gambar Fret (Garis Horizontal)
                for (int i = 0; i <= totalFrets; i++)
                  Positioned(
                    top: fretSpacing * (i + 0.5),
                    left: stringSpacing,
                    right: stringSpacing,
                    child: Container(
                      height: i == 0 ? 4 : 2, // Fret 0 (nut) lebih tebal
                      color: i == 0 ? Colors.white70 : Colors.white24,
                    ),
                  ),

                // 2. Gambar Senar & Area Deteksi Sentuhan
                for (int s = 1; s <= 6; s++) ...[
                  // Garis Senar
                  Positioned(
                    top: fretSpacing * 0.5,
                    bottom: fretSpacing * 0.5,
                    left: stringSpacing * s - 1,
                    child: Container(
                      width: 2,
                      color: Colors.white12,
                    ),
                  ),

                  // Area Sensitif Sentuhan (Transparent Buttons)
                  for (int f = 0; f <= totalFrets; f++)
                    Positioned(
                      top: fretSpacing * f,
                      left: stringSpacing * s - (stringSpacing / 2),
                      width: stringSpacing,
                      height: fretSpacing,
                      child: GestureDetector(
                        onTap: () {
                          // Kirim data senar (1-6) dan fret (0-5)
                          onTap(FretPosition(string: s, fret: f));
                        },
                        child: Container(
                          color: Colors.transparent, // Hitbox
                        ),
                      ),
                    ),
                ],

                // 3. Gambar Titik Input User
                for (var pos in userInput)
                  _buildNoteDot(pos, stringSpacing, fretSpacing),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildNoteDot(FretPosition pos, double stringSpc, double fretSpc) {
    final double dotSize = pos.fret == 0 ? 16 : 24;

    // ── PERBAIKAN UTAMA: Menggunakan left dan top, bukan centerX/Y ──
    double leftPosition = (stringSpc * pos.string) - (dotSize / 2);
    double topPosition = pos.fret == 0 
        ? (fretSpc * 0.5) - (dotSize / 2) // Di tengah garis nut (fret 0)
        : (fretSpc * pos.fret) + (fretSpc * 0.5) - (dotSize / 2); // Di tengah kolom fret

    return Positioned(
      key: ValueKey('dot_${pos.string}_${pos.fret}'),
      left: leftPosition,
      top: topPosition,
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accentColor,
          boxShadow: [
            BoxShadow(
              color: accentColor.withAlpha((0.7 * 255).round()), // Mengganti withOpacity yang deprecated
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: pos.fret == 0 
          ? const Center(child: Icon(Icons.close, size: 10, color: Color(0xFF070A0F))) // Tanda open string
          : null,
      ),
    );
  }
}