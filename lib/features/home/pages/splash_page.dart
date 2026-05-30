import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/profile/profile.dart';
import 'home_page.dart';
import 'profile_setup_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _progressController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late AnimationController _ringController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _logoGlow;
  late Animation<double> _textFade;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _captionSlide;
  late Animation<double> _progressAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _ringAnim;

  static const _cyan   = Color(0xFF00E5FF);
  static const _purple = Color(0xFF9D00FF);
  static const _bg     = Color(0xFF070A0F);

  bool _imagesCached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesCached) {
      _imagesCached = true;
      precacheImage(const AssetImage('assets/images/iconapp.png'), context);
      precacheImage(const AssetImage('assets/images/man.jpg'), context);
      precacheImage(const AssetImage('assets/images/woman.jpg'), context);
    }
  }

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900),
    );
    _logoScale = CurvedAnimation(parent: _logoController, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.3, end: 1.0));
    _logoFade = CurvedAnimation(parent: _logoController, curve: const Interval(0, 0.5))
        .drive(Tween(begin: 0.0, end: 1.0));

    _pulseController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    _ringController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 3000),
    )..repeat();
    _ringAnim = _ringController;

    _textController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700),
    );
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _titleSlide = CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic)
        .drive(Tween(begin: const Offset(0, 0.4), end: Offset.zero));
    _captionSlide = CurvedAnimation(
      parent: _textController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ).drive(Tween(begin: const Offset(0, 0.6), end: Offset.zero));

    _logoGlow = _pulseAnim.drive(Tween(begin: 0.3, end: 0.8));

    _progressController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2200),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();

    await Future.delayed(const Duration(milliseconds: 2600));
    if (!mounted) return;

    // ── Cek profil: belum ada → ProfileSetupPage, sudah ada → HomePage ──
    final Widget destination = ProfileService.instance.hasProfile
        ? const HomePage()
        : const ProfileSetupPage();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _progressController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildBgGrid()),
            Column(
              children: [
                const Spacer(flex: 3),
                _buildLogo(),
                const SizedBox(height: 36),
                _buildText(),
                const Spacer(flex: 2),
                _buildProgressBar(),
                const SizedBox(height: 40),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBgGrid() => CustomPaint(painter: _GridPainter());

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoController, _pulseAnim, _ringAnim]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _logoFade,
          child: ScaleTransition(
            scale: _logoScale,
            child: SizedBox(
              width: 140, height: 140,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140, height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: _cyan.withOpacity(0.12 + 0.1 * _pulseAnim.value),
                        blurRadius: 40 + 20 * _pulseAnim.value,
                        spreadRadius: 8,
                      )],
                    ),
                  ),
                  Transform.rotate(
                    angle: _ringAnim.value * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(130, 130),
                      painter: _DashedRingPainter(
                        color: _cyan.withOpacity(0.25), strokeWidth: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 110 + 8 * _pulseAnim.value,
                    height: 110 + 8 * _pulseAnim.value,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _cyan.withOpacity(0.15 + 0.15 * _pulseAnim.value),
                        width: 1,
                      ),
                    ),
                  ),
                  Container(
                    width: 96, height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_cyan.withOpacity(0.15), _purple.withOpacity(0.2)],
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: _cyan.withOpacity(0.4 + 0.2 * _pulseAnim.value),
                        width: 2,
                      ),
                      boxShadow: [BoxShadow(
                        color: _cyan.withOpacity(_logoGlow.value * 0.4),
                        blurRadius: 20, spreadRadius: 2,
                      )],
                    ),
                    child: Center(child: _buildLogoIcon()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogoIcon() {
    // Sudah di-precache di main.dart → langsung muncul tanpa jank
    return ClipOval(
      child: Image.asset(
        'assets/images/iconapp.png',
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.music_note_rounded,
          color: _cyan,
          size: 44,
          shadows: [Shadow(color: _cyan.withOpacity(0.8), blurRadius: 12)],
        ),
      ),
    );
  }

  Widget _buildText() {
    return FadeTransition(
      opacity: _textFade,
      child: Column(
        children: [
          SlideTransition(
            position: _titleSlide,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_cyan, Color(0xFF00BFFF), _purple],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: const Text(
                'CLEAN CHORD',
                style: TextStyle(
                  fontFamily: 'Orbitron', fontSize: 28,
                  fontWeight: FontWeight.w900, letterSpacing: 4, color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SlideTransition(
            position: _titleSlide,
            child: Container(
              width: 180, height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, _cyan.withOpacity(0.6), Colors.transparent],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SlideTransition(
            position: _captionSlide,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_outline_rounded, color: _cyan.withOpacity(0.7), size: 13),
                const SizedBox(width: 6),
                Text(
                  'Mulailah sebagai pemula',
                  style: TextStyle(
                    fontFamily: 'Orbitron', fontSize: 12,
                    color: Colors.white.withOpacity(0.5), letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.star_outline_rounded, color: _cyan.withOpacity(0.7), size: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: AnimatedBuilder(
        animation: _progressAnim,
        builder: (context, _) {
          final pct = _progressAnim.value;
          return Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Stack(children: [
                  Container(height: 3, color: Colors.white.withOpacity(0.06)),
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [_cyan, _purple]),
                        boxShadow: [BoxShadow(color: _cyan.withOpacity(0.6), blurRadius: 6)],
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Text(
                _loadingLabel(pct),
                style: TextStyle(
                  fontFamily: 'Orbitron', fontSize: 9,
                  color: Colors.white.withOpacity(0.3), letterSpacing: 2,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _loadingLabel(double pct) {
    if (pct < 0.3) return 'MEMUAT DATA...';
    if (pct < 0.6) return 'MENYIAPKAN LEVEL...';
    if (pct < 0.9) return 'HAMPIR SIAP...';
    return 'SELAMAT DATANG!';
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(0.03)
      ..strokeWidth = 1;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(_GridPainter _) => false;
}

class _DashedRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  const _DashedRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const dashCount   = 16;
    const dashAngle   = 2 * math.pi / dashCount;
    const gapFraction = 0.4;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * dashAngle, dashAngle * (1 - gapFraction), false, paint,
      );
    }
  }
  @override
  bool shouldRepaint(_DashedRingPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
