import 'dart:math' as math;
import 'package:flutter/material.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnim;
  late List<Animation<double>> _fadeAnims;

  // ── Dummy Data ──────────────────────────────────────────────
  static const String _username = 'Rangga_Coustic';
  static const String _level = 'Pemula';
  static const int _xp = 340;
  static const int _maxXp = 500;
  static const double _overallProgress = 0.38;

  static const List<_StatData> _stats = [
    _StatData(Icons.library_music_rounded, 'Chord\nDipelajari', '24',
        Color(0xFF00FFFF)),
    _StatData(Icons.quiz_rounded, 'Kuis\nSelesai', '8', Color(0xFFFF00FF)),
    _StatData(
        Icons.gps_fixed_rounded, 'Akurasi\nKuis', '82%', Color(0xFF9D00FF)),
    _StatData(Icons.local_fire_department_rounded, 'Streak\nBelajar', '5 hari',
        Color(0xFFFFAA00)),
    _StatData(Icons.draw_rounded, 'Progress\nGambar', '12/30', Color(0xFF00FF88)),
    _StatData(
        Icons.stars_rounded, 'Total XP', '340 XP', Color(0xFFFF4488)),
  ];

  static const List<_LevelData> _levels = [
    _LevelData('Pemula', Icons.emoji_events_rounded, Color(0xFF00FFFF), true,
        'Chord dasar, kunci mayor & minor'),
    _LevelData('Menengah', Icons.lock_rounded, Color(0xFFFF00FF), false,
        'Chord 7th, barre chord, transisi'),
    _LevelData('Mahir', Icons.lock_rounded, Color(0xFF9D00FF), false,
        'Chord jazz, fingerstyle, improvisasi'),
  ];

  static const List<_ActivityData> _activities = [
    _ActivityData(Icons.check_circle_rounded, 'Menyelesaikan kuis chord dasar',
        '2 jam lalu', Color(0xFF00FFFF)),
    _ActivityData(Icons.draw_rounded, 'Berhasil menggambar chord Em',
        '5 jam lalu', Color(0xFF00FF88)),
    _ActivityData(Icons.trending_up_rounded, 'Akurasi meningkat menjadi 82%',
        'Kemarin', Color(0xFFFF4488)),
    _ActivityData(Icons.menu_book_rounded, 'Membuka materi chord mayor',
        '2 hari lalu', Color(0xFF9D00FF)),
    _ActivityData(Icons.local_fire_department_rounded,
        'Streak 5 hari berturut-turut', '3 hari lalu', Color(0xFFFFAA00)),
  ];
  // ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _pulseAnim =
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnims = List.generate(5, (i) {
      return CurvedAnimation(
        parent: _fadeController,
        curve: Interval(i * 0.12, 0.6 + i * 0.08, curve: Curves.easeOutBack),
      );
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(
              child: _buildSectionLabel('STATISTIK BELAJAR',
                  const Color(0xFF00FFFF), _fadeAnims[1]),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildStatsGrid(_fadeAnims[1]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: _buildSectionLabel('LEVEL PROGRESSION',
                  const Color(0xFFFF00FF), _fadeAnims[2]),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(
                child: _buildLevels(_fadeAnims[2]),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: _buildSectionLabel('AKTIVITAS TERAKHIR',
                  const Color(0xFF9D00FF), _fadeAnims[3]),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverToBoxAdapter(
                child: _buildActivities(_fadeAnims[3]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnim, _fadeAnims[0]]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeAnims[0],
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.15),
              end: Offset.zero,
            ).animate(_fadeAnims[0]),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF00FFFF)
                      .withOpacity(0.3 + 0.2 * _pulseAnim.value),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FFFF)
                        .withOpacity(0.08 + 0.06 * _pulseAnim.value),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  // Info
                  Expanded(child: _buildProfileInfo()),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF001A1A), Color(0xFF003333)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF00FFFF)
                  .withOpacity(0.5 + 0.3 * _pulseAnim.value),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFFF)
                    .withOpacity(0.2 + 0.15 * _pulseAnim.value),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded,
              color: Color(0xFF00FFFF), size: 36),
        );
      },
    );
  }

  Widget _buildProfileInfo() {
    final xpPercent = _xp / _maxXp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username
        Text(
          _username,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        // Badge level
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF00FFFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.4), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFF00FFFF), size: 12),
              const SizedBox(width: 4),
              const Text(
                _level,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: Color(0xFF00FFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // XP bar
        Row(
          children: [
            const Text(
              'XP',
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: Colors.grey,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, _) {
                  return Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: xpPercent,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00FFFF), Color(0xFF0088FF)],
                            ),
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00FFFF).withOpacity(
                                    0.5 + 0.3 * _pulseAnim.value),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_xp/$_maxXp',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                color: Color(0xFF00FFFF),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // Overall progress
        Text(
          'Progress: ${(_overallProgress * 100).toInt()}%',
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── SECTION LABEL ───────────────────────────────────────────
  Widget _buildSectionLabel(
      String title, Color color, Animation<double> anim) {
    return FadeTransition(
      opacity: anim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.7), blurRadius: 6),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Orbitron',
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [Shadow(color: color.withOpacity(0.6), blurRadius: 8)],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STATS GRID ───────────────────────────────────────────────
  Widget _buildStatsGrid(Animation<double> anim) {
    return FadeTransition(
      opacity: anim,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.92,
        ),
        itemCount: _stats.length,
        itemBuilder: (context, i) => _StatCard(
          data: _stats[i],
          pulseAnim: _pulseAnim,
        ),
      ),
    );
  }

  // ── LEVELS ──────────────────────────────────────────────────
  Widget _buildLevels(Animation<double> anim) {
    return FadeTransition(
      opacity: anim,
      child: Column(
        children: _levels
            .map((lvl) => _LevelCard(data: lvl, pulseAnim: _pulseAnim))
            .toList(),
      ),
    );
  }

  // ── ACTIVITIES ──────────────────────────────────────────────
  Widget _buildActivities(Animation<double> anim) {
    return FadeTransition(
      opacity: anim,
      child: Column(
        children: List.generate(_activities.length, (i) {
          final act = _activities[i];
          final isLast = i == _activities.length - 1;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timeline
                SizedBox(
                  width: 36,
                  child: Column(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: act.color.withOpacity(0.12),
                          border: Border.all(
                              color: act.color.withOpacity(0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                                color: act.color.withOpacity(0.2),
                                blurRadius: 8),
                          ],
                        ),
                        child: Icon(act.icon, color: act.color, size: 15),
                      ),
                      if (!isLast)
                        Expanded(
                          child: Container(
                            width: 1.5,
                            color: act.color.withOpacity(0.2),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Card
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D0D),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: act.color.withOpacity(0.2), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.title,
                          style: const TextStyle(
                            fontFamily: 'Orbitron',
                            color: Colors.white,
                            fontSize: 11.5,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          act.time,
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            color: act.color.withOpacity(0.7),
                            fontSize: 9.5,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── STAT CARD WIDGET ────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _StatData data;
  final Animation<double> pulseAnim;

  const _StatCard({required this.data, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: data.color.withOpacity(0.25 + 0.15 * pulseAnim.value),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: data.color
                    .withOpacity(0.05 + 0.04 * pulseAnim.value),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.color.withOpacity(0.12),
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(data.icon, color: data.color, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                data.value,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: data.color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(color: data.color.withOpacity(0.6), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Orbitron',
                  color: Colors.white38,
                  fontSize: 8.5,
                  letterSpacing: 0.3,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── LEVEL CARD WIDGET ───────────────────────────────────────
class _LevelCard extends StatelessWidget {
  final _LevelData data;
  final Animation<double> pulseAnim;

  const _LevelCard({required this.data, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: data.unlocked ? 1.0 : 0.4,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0D0D0D),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: data.unlocked
                    ? data.color.withOpacity(0.4 + 0.2 * pulseAnim.value)
                    : Colors.white12,
                width: 1.5,
              ),
              boxShadow: data.unlocked
                  ? [
                      BoxShadow(
                        color: data.color
                            .withOpacity(0.08 + 0.06 * pulseAnim.value),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Icon circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.color.withOpacity(data.unlocked ? 0.15 : 0.05),
                    border: Border.all(
                      color: data.unlocked
                          ? data.color.withOpacity(0.5)
                          : Colors.white12,
                      width: 1.5,
                    ),
                    boxShadow: data.unlocked
                        ? [
                            BoxShadow(
                              color: data.color.withOpacity(0.25),
                              blurRadius: 12,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(data.icon,
                      color: data.unlocked ? data.color : Colors.white24,
                      size: 22),
                ),
                const SizedBox(width: 14),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            data.name,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              color: data.unlocked
                                  ? Colors.white
                                  : Colors.white38,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (data.unlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: data.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: data.color.withOpacity(0.4),
                                    width: 1),
                              ),
                              child: Text(
                                'AKTIF',
                                style: TextStyle(
                                  fontFamily: 'Orbitron',
                                  color: data.color,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Orbitron',
                          color: Colors.white38,
                          fontSize: 9.5,
                          letterSpacing: 0.2,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // Lock / check
                Icon(
                  data.unlocked
                      ? Icons.check_circle_rounded
                      : Icons.lock_rounded,
                  color: data.unlocked ? data.color : Colors.white12,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── DATA CLASSES ────────────────────────────────────────────
class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatData(this.icon, this.label, this.value, this.color);
}

class _LevelData {
  final String name;
  final IconData icon;
  final Color color;
  final bool unlocked;
  final String subtitle;

  const _LevelData(this.name, this.icon, this.color, this.unlocked,
      this.subtitle);
}

class _ActivityData {
  final IconData icon;
  final String title;
  final String time;
  final Color color;

  const _ActivityData(this.icon, this.title, this.time, this.color);
}