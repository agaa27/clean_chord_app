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
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    _scanAnim = CurvedAnimation(parent: _scanController, curve: Curves.linear);

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
          child: const Icon(
            Icons.queue_music_rounded,
            color: Colors.cyanAccent,
            size: 26,
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

        // Warna & icon per difficulty
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
          default: // Pemula
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
    return AnimatedBuilder(
      animation: _scanAnim,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 3,
            width: double.infinity,
            color: Colors.white.withOpacity(0.04),
            child: FractionallySizedBox(
              alignment: Alignment(_scanAnim.value * 2 - 1, 0),
              widthFactor: 0.35,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.cyanAccent.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.6),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
