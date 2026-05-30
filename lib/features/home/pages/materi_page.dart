import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:clean_chord/features/kuis_chord/pages/kuis_chord_page.dart';
import 'package:clean_chord/features/metronom/pages/metronom_page.dart';
import '../widgets/menu_card.dart';
import 'package:clean_chord/features/pustaka_chord/pages/pustaka_chord_page.dart';
import 'package:clean_chord/features/gambar_chord/pages/gambar_chord_page.dart';
import '../../../core/progression/progression.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;
  late AnimationController _gridFadeController;
  late Animation<double> _pulseAnim;
  late Animation<double> _scanAnim;
  late List<Animation<double>> _cardAnims;

  int _colorIndex = 0;
  double _lastScanValue = 0.0; // untuk deteksi wrap-around

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    )..repeat();
    _scanAnim = CurvedAnimation(parent: _scanController, curve: Curves.linear);

    // .repeat() tidak pernah trigger AnimationStatus.completed,
    // jadi kita deteksi wrap-around manual: kalau value tiba-tiba
    // lebih kecil dari value sebelumnya, berarti satu siklus baru dimulai.
    _scanController.addListener(() {
      final current = _scanController.value;
      if (current < _lastScanValue) {
        // wrap-around terjadi → ganti warna
        setState(() {
          _colorIndex = (_colorIndex + 1) % 4;
        });
      }
      _lastScanValue = current;
    });

    _gridFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _cardAnims = List.generate(4, (i) {
      return CurvedAnimation(
        parent: _gridFadeController,
        curve: Interval(i * 0.15, 0.6 + i * 0.1, curve: Curves.easeOutBack),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _gridFadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            _buildSectionLabel('Alat'),
            const SizedBox(height: 12),
            Expanded(child: _buildGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border(
              bottom: BorderSide(
                color: Colors.cyanAccent.withOpacity(
                  0.15 + 0.1 * _pulseAnim.value,
                ),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildLogoIcon(),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.cyanAccent,
                            Colors.cyanAccent.withOpacity(
                              0.6 + 0.4 * _pulseAnim.value,
                            ),
                            const Color(0xFF00BFFF),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Clean Chord',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Suitable for beginners',
                        style: TextStyle(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 16),
              _buildScanBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoIcon() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.cyanAccent.withOpacity(0.08),
            border: Border.all(
              color: Colors.cyanAccent.withOpacity(
                0.4 + 0.3 * _pulseAnim.value,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(
                  0.15 + 0.1 * _pulseAnim.value,
                ),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/iconapp.png',
              fit: BoxFit.cover,
              // Sudah di-precache di main.dart, jadi langsung muncul tanpa render delay
              errorBuilder: (_, __, ___) => const Icon(
                Icons.queue_music_rounded,
                color: Colors.cyanAccent,
                size: 26,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge() {
    return ListenableBuilder(
      listenable: ProgressionService.instance,
      builder: (context, _) {
        final p          = ProgressionService.instance.progress;
        final levelId    = p.unlockedUpToLevel;
        final difficulty = ProgressionConfig.difficultyOf(levelId);

        Color color;
        IconData icon;
        switch (difficulty) {
          case 'Menengah':
            color = const Color(0xFFBD00FF);
            icon  = Icons.star_half_rounded;
            break;
          case 'Mahir':
            color = const Color(0xFFFFAA00);
            icon  = Icons.star_rounded;
            break;
          default:
            color = Colors.cyanAccent;
            icon  = Icons.star_outline_rounded;
        }

        return AnimatedBuilder(
          animation: _pulseAnim,
          builder: (context, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: color.withOpacity(0.3 + 0.2 * _pulseAnim.value),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color.withOpacity(0.6 + 0.4 * _pulseAnim.value), size: 10),
                  const SizedBox(width: 5),
                  Text(
                    difficulty.toUpperCase(),
                    style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScanBar() {
    return SizedBox(
      height: 3,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _scanAnim,
        builder: (context, _) => CustomPaint(
          painter: _ScanBarPainter(_scanAnim.value, _colorIndex),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: Colors.cyanAccent,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final alatItems = [
      _CardData(
        color: const Color(0xFFFF00FF),
        title: 'Pustaka Chord',
        subtitle: 'Semua chord',
        icon: Icons.library_music_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PustakaChordPage()),
        ),
      ),
      _CardData(
        color: const Color(0xFF9D00FF),
        title: 'Metronom',
        subtitle: 'Atur tempo latihan',
        icon: Icons.av_timer,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MetronomePage()),
        ),
      ),
    ];

    final modulItems = [
      _CardData(
        color: const Color(0xFF00FFFF),
        title: 'Kuis Chord',
        subtitle: 'Tebak nama chord',
        icon: Icons.quiz,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => KuisChordPage()),
        ),
      ),
      _CardData(
        color: const Color(0xFF00FF9F),
        title: 'Gambar Chord',
        subtitle: 'Tebak lalu gambar',
        icon: Icons.fingerprint_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GambarChordPage()),
        ),
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: alatItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) {
                return AnimatedBuilder(
                  animation: _cardAnims[i],
                  builder: (context, child) {
                    final v = _cardAnims[i].value;
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - v)),
                      child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
                    );
                  },
                  child: MenuCard(
                    color: alatItems[i].color,
                    title: alatItems[i].title,
                    subtitle: alatItems[i].subtitle,
                    icon: alatItems[i].icon,
                    onTap: alatItems[i].onTap,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionLabel('Modul Belajar'),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modulItems.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, i) {
                return AnimatedBuilder(
                  animation: _cardAnims[i + 2],
                  builder: (context, child) {
                    final v = _cardAnims[i + 2].value;
                    return Transform.translate(
                      offset: Offset(0, 30 * (1 - v)),
                      child: Opacity(opacity: v.clamp(0.0, 1.0), child: child),
                    );
                  },
                  child: MenuCard(
                    color: modulItems[i].color,
                    title: modulItems[i].title,
                    subtitle: modulItems[i].subtitle,
                    icon: modulItems[i].icon,
                    onTap: modulItems[i].onTap,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CardData {
  final Color color;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _CardData({
    required this.color,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });
}

// ── _ScanBarPainter ───────────────────────────────────────────
// colorIndex dioper dari state dan hanya berubah saat wrap-around terdeteksi,
// sehingga warna stabil penuh selama satu pass kiri→kanan.
class _ScanBarPainter extends CustomPainter {
  final double progress;
  final int colorIndex;

  static const _palette = [
    Color(0xFF00FFFF), // cyan    — Kuis Chord
    Color(0xFFFF00FF), // magenta — Pustaka Chord
    Color(0xFF9D00FF), // purple  — Metronom
    Color(0xFF00FF9F), // mint    — Gambar Chord
  ];

  static const double _cometWidth = 0.38;

  const _ScanBarPainter(this.progress, this.colorIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Track background
    final bgPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.04);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(2)),
      bgPaint,
    );

    final baseColor = _palette[colorIndex % _palette.length];

    final travel  = 1.0 + _cometWidth;
    final centerX = (progress * travel - _cometWidth / 2) * w;
    final halfW   = _cometWidth * w / 2;

    final left  = centerX - halfW;
    final right = centerX + halfW;

    final rect = Rect.fromLTRB(left, 0, right, h);
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        baseColor.withOpacity(0.5),
        baseColor.withOpacity(0.95),
        baseColor.withOpacity(0.5),
        Colors.transparent,
      ],
      stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(2)),
      paint,
    );

    // Glow layer
    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          baseColor.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.inflate(1),
        const Radius.circular(3),
      ),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_ScanBarPainter old) =>
      old.progress != progress || old.colorIndex != colorIndex;
}