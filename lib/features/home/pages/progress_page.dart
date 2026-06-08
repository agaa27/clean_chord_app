import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/progression/progression.dart';
import '../../../core/profile/profile.dart';
import 'profile_setup_page.dart';

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

  static const int _xpPerLevel = 500;

  static const List<_DiffData> _diffs = [
    _DiffData(
      'Pemula',
      Color(0xFF00FFFF),
      'Chord dasar, kunci mayor & minor',
      1,
      5,
    ),
    _DiffData(
      'Menengah',
      Color(0xFFFF00FF),
      'Chord 7th, barre chord, transisi',
      6,
      13,
    ),
    _DiffData(
      'Mahir',
      Color(0xFF9D00FF),
      'Chord jazz, fingerstyle, improvisasi',
      14,
      20,
    ),
  ];

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

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnims = List.generate(
      5,
      (i) => CurvedAnimation(
        parent: _fadeController,
        curve: Interval(i * 0.12, 0.6 + i * 0.08, curve: Curves.easeOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────────
  IconData _iconForFeature(String key) {
    switch (key) {
      case ProgressionConfig.featureQuiz:
        return Icons.quiz_rounded;
      case ProgressionConfig.featureGambar:
        return Icons.draw_rounded;
      case ProgressionConfig.featureEar:
        return Icons.hearing_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _colorForFeature(String key) {
    switch (key) {
      case ProgressionConfig.featureQuiz:
        return const Color(0xFF00FFFF);
      case ProgressionConfig.featureGambar:
        return const Color(0xFF00FF88);
      case ProgressionConfig.featureEar:
        return const Color(0xFF9D00FF);
      default:
        return const Color(0xFFFFAA00);
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  // ── BUILD ───────────────────────────────────────────────────
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
              child: _buildSectionLabel(
                'STATISTIK BELAJAR',
                const Color(0xFF00FFFF),
                _fadeAnims[1],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: _buildStatsGrid(_fadeAnims[1])),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: _buildSectionLabel(
                'LEVEL PROGRESSION',
                const Color(0xFFFF00FF),
                _fadeAnims[2],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: _buildLevels(_fadeAnims[2])),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: _buildSectionLabel(
                'AKTIVITAS TERAKHIR',
                const Color(0xFF9D00FF),
                _fadeAnims[3],
              ),
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

  // ── HEADER — live dari ProfileService + ProgressionService ──
  Widget _buildHeader() {
    return ListenableBuilder(
      // Dengerin keduanya: profil berubah saat edit, progression berubah saat main
      listenable: Listenable.merge([
        ProgressionService.instance,
        ProfileService.instance,
      ]),
      builder: (context, _) {
        final p = ProgressionService.instance.progress;
        final xp = p.totalXp;
        final xpInTier = xp % _xpPerLevel;
        final xpFraction = xpInTier / _xpPerLevel;
        final levelLabel = ProgressionConfig.difficultyOf(p.unlockedUpToLevel);
        final overallPct =
            (p.unlockedUpToLevel / ProgressionConfig.totalLevels * 100).toInt();

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
                      color: const Color(
                        0xFF00FFFF,
                      ).withOpacity(0.3 + 0.2 * _pulseAnim.value),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(
                          0xFF00FFFF,
                        ).withOpacity(0.08 + 0.06 * _pulseAnim.value),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildAvatar(),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildProfileInfo(
                          xp: xp,
                          xpFraction: xpFraction,
                          levelLabel: levelLabel,
                          overallPct: overallPct,
                          context: context,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Avatar: baca dari ProfileService ───────────────────────
  Widget _buildAvatar() {
    final profile = ProfileService.instance.profile;
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) => Container(
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
            color: const Color(
              0xFF00FFFF,
            ).withOpacity(0.5 + 0.3 * _pulseAnim.value),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF00FFFF,
              ).withOpacity(0.2 + 0.15 * _pulseAnim.value),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(child: _avatarWidget(profile)),
      ),
    );
  }

  Widget _avatarWidget(UserProfile? profile) {
    if (profile == null) {
      return const Icon(
        Icons.person_rounded,
        color: Color(0xFF00FFFF),
        size: 36,
      );
    }
    if (profile.avatarType == 'file') {
      return Image.file(
        File(profile.avatarPath),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        cacheWidth: 144,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.person_rounded,
          color: Color(0xFF00FFFF),
          size: 36,
        ),
      );
    }
    // avatarType == 'asset' — man.jpg / woman.jpg sudah di-precache di splash
    return Image.asset(
      profile.avatarPath,
      width: 72,
      height: 72,
      fit: BoxFit.cover,
      cacheWidth: 144,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) =>
          const Icon(Icons.person_rounded, color: Color(0xFF00FFFF), size: 36),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupPage(isEdit: true)),
      ),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, _) => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00FFFF).withOpacity(0.06),
            border: Border.all(
              color: const Color(
                0xFF00FFFF,
              ).withOpacity(0.2 + 0.1 * _pulseAnim.value),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.edit_rounded,
            color: Color(0xFF00FFFF),
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDeleteConfirmDialog(context),
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, _) => Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFF2D55).withOpacity(0.06),
            border: Border.all(
              color: const Color(
                0xFFFF2D55,
              ).withOpacity(0.2 + 0.1 * _pulseAnim.value),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: Color(0xFFFF2D55),
            size: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (ctx) => _DeleteConfirmDialog(pulseAnim: _pulseAnim),
    );
  }

  Widget _buildProfileInfo({
    required int xp,
    required double xpFraction,
    required String levelLabel,
    required int overallPct,
    required BuildContext context,
  }) {
    final name = ProfileService.instance.profile?.name ?? 'Pengguna';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        // Level badge + tombol edit & hapus dalam satu Row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF00FFFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00FFFF).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFF00FFFF),
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    levelLabel,
                    style: const TextStyle(
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
            const SizedBox(width: 8),
            _buildEditButton(context),
            const SizedBox(width: 6),
            _buildDeleteButton(context),
          ],
        ),
        const SizedBox(height: 10),
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
                builder: (context, _) => Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: xpFraction.clamp(0.0, 1.0),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00FFFF), Color(0xFF0088FF)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF00FFFF,
                              ).withOpacity(0.5 + 0.3 * _pulseAnim.value),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$xp XP',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                color: Color(0xFF00FFFF),
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Progress: $overallPct%',
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
  Widget _buildSectionLabel(String title, Color color, Animation<double> anim) {
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

  // ── STATS GRID ──────────────────────────────────────────────
  Widget _buildStatsGrid(Animation<double> anim) {
    return ListenableBuilder(
      listenable: ProgressionService.instance,
      builder: (context, _) {
        final p = ProgressionService.instance.progress;

        final quizDone = p.completedLevels
            .where((k) => k.startsWith('${ProgressionConfig.featureQuiz}_'))
            .length;
        final gambarDone = p.completedLevels
            .where((k) => k.startsWith('${ProgressionConfig.featureGambar}_'))
            .length;
        final totalDone = quizDone + gambarDone;
        final totalLevels = ProgressionConfig.totalLevels * 2;

        int streak = 0;
        if (p.recentActivities.isNotEmpty) {
          final dates =
              p.recentActivities
                  .map(
                    (a) => DateTime(
                      a.timestamp.year,
                      a.timestamp.month,
                      a.timestamp.day,
                    ),
                  )
                  .toSet()
                  .toList()
                ..sort((a, b) => b.compareTo(a));
          final today = DateTime.now();
          DateTime check = DateTime(today.year, today.month, today.day);
          for (final d in dates) {
            if (d == check || d == check.subtract(const Duration(days: 1))) {
              streak++;
              check = d;
            } else {
              break;
            }
          }
        }

        final liveStats = [
          _StatData(
            Icons.quiz_rounded,
            'Kuis\nSelesai',
            '$quizDone',
            const Color(0xFFFF00FF),
          ),
          _StatData(
            Icons.draw_rounded,
            'Gambar\nSelesai',
            '$gambarDone',
            const Color(0xFF00FF88),
          ),
          _StatData(
            Icons.layers_rounded,
            'Total\nSelesai',
            '$totalDone/$totalLevels',
            const Color(0xFF00FFFF),
          ),
          _StatData(
            Icons.local_fire_department_rounded,
            'Streak\nBelajar',
            '$streak hari',
            const Color(0xFFFFAA00),
          ),
          _StatData(
            Icons.lock_open_rounded,
            'Level\nTerbuka',
            '${p.unlockedUpToLevel}/${ProgressionConfig.totalLevels}',
            const Color(0xFF9D00FF),
          ),
          _StatData(
            Icons.stars_rounded,
            'Total XP',
            '${p.totalXp} XP',
            const Color(0xFFFF4488),
          ),
        ];

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
            itemCount: liveStats.length,
            itemBuilder: (context, i) =>
                _StatCard(data: liveStats[i], pulseAnim: _pulseAnim),
          ),
        );
      },
    );
  }

  // ── LEVELS ──────────────────────────────────────────────────
  Widget _buildLevels(Animation<double> anim) {
    return ListenableBuilder(
      listenable: ProgressionService.instance,
      builder: (context, _) {
        final p = ProgressionService.instance.progress;
        final unlocked = p.unlockedUpToLevel;
        return FadeTransition(
          opacity: anim,
          child: Column(
            children: _diffs.map((d) {
              final isUnlocked = unlocked >= d.startLevel;
              int quizCompleted = 0, gambarCompleted = 0;
              final totalInDiff = d.endLevel - d.startLevel + 1;
              for (int lvl = d.startLevel; lvl <= d.endLevel; lvl++) {
                if (p.isLevelCompleted(ProgressionConfig.featureQuiz, lvl))
                  quizCompleted++;
                if (p.isLevelCompleted(ProgressionConfig.featureGambar, lvl))
                  gambarCompleted++;
              }
              return _DiffCard(
                data: d,
                unlocked: isUnlocked,
                pulseAnim: _pulseAnim,
                quizCompleted: quizCompleted,
                gambarCompleted: gambarCompleted,
                totalInDiff: totalInDiff,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ── ACTIVITIES ──────────────────────────────────────────────
  Widget _buildActivities(Animation<double> anim) {
    return ListenableBuilder(
      listenable: ProgressionService.instance,
      builder: (context, _) {
        final activities =
            ProgressionService.instance.progress.recentActivities;

        if (activities.isEmpty) {
          return FadeTransition(
            opacity: anim,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.inbox_rounded,
                      color: Colors.white12,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada aktivitas.\nMulai belajar sekarang!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: Colors.white24,
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return FadeTransition(
          opacity: anim,
          child: Column(
            children: List.generate(activities.length, (i) {
              final act = activities[i];
              final isLast = i == activities.length - 1;
              final color = _colorForFeature(act.featureKey);
              final icon = _iconForFeature(act.featureKey);
              final time = _formatTime(act.timestamp);

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 36,
                      child: Column(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color.withOpacity(0.12),
                              border: Border.all(
                                color: color.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(icon, color: color, size: 15),
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                width: 1.5,
                                color: color.withOpacity(0.2),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D0D),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: color.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              act.message,
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                color: Colors.white,
                                fontSize: 11.5,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                    fontFamily: 'Orbitron',
                                    color: color.withOpacity(0.7),
                                    fontSize: 9.5,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (act.xpEarned > 0)
                                  Text(
                                    '+${act.xpEarned} XP',
                                    style: TextStyle(
                                      fontFamily: 'Orbitron',
                                      color: color.withOpacity(0.8),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
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
      },
    );
  }
}

// ── _StatCard ────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final _StatData data;
  final Animation<double> pulseAnim;
  const _StatCard({required this.data, required this.pulseAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) => Container(
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
              color: data.color.withOpacity(0.05 + 0.04 * pulseAnim.value),
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
                  BoxShadow(color: data.color.withOpacity(0.2), blurRadius: 8),
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
      ),
    );
  }
}

// ── _DiffCard ────────────────────────────────────────────────
class _DiffCard extends StatelessWidget {
  final _DiffData data;
  final bool unlocked;
  final Animation<double> pulseAnim;
  final int quizCompleted, gambarCompleted, totalInDiff;
  const _DiffCard({
    required this.data,
    required this.unlocked,
    required this.pulseAnim,
    this.quizCompleted = 0,
    this.gambarCompleted = 0,
    this.totalInDiff = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (context, _) => Opacity(
        opacity: unlocked ? 1.0 : 0.4,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D0D),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unlocked
                  ? data.color.withOpacity(0.4 + 0.2 * pulseAnim.value)
                  : Colors.white12,
              width: 1.5,
            ),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: data.color.withOpacity(
                        0.08 + 0.06 * pulseAnim.value,
                      ),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.color.withOpacity(unlocked ? 0.15 : 0.05),
                  border: Border.all(
                    color: unlocked
                        ? data.color.withOpacity(0.5)
                        : Colors.white12,
                    width: 1.5,
                  ),
                  boxShadow: unlocked
                      ? [
                          BoxShadow(
                            color: data.color.withOpacity(0.25),
                            blurRadius: 12,
                          ),
                        ]
                      : [],
                ),
                child: Icon(
                  unlocked ? Icons.emoji_events_rounded : Icons.lock_rounded,
                  color: unlocked ? data.color : Colors.white24,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
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
                            color: unlocked ? Colors.white : Colors.white38,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (unlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: data.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: data.color.withOpacity(0.4),
                                width: 1,
                              ),
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
                    if (unlocked && totalInDiff > 0) ...[
                      const SizedBox(height: 8),
                      _FeatureProgressRow(
                        icon: Icons.quiz_rounded,
                        label: 'Kuis',
                        done: quizCompleted,
                        total: totalInDiff,
                        color: const Color(0xFF00FFFF),
                      ),
                      const SizedBox(height: 4),
                      _FeatureProgressRow(
                        icon: Icons.draw_rounded,
                        label: 'Gambar',
                        done: gambarCompleted,
                        total: totalInDiff,
                        color: const Color(0xFF00FF88),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                unlocked ? Icons.check_circle_rounded : Icons.lock_rounded,
                color: unlocked ? data.color : Colors.white12,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _FeatureProgressRow ──────────────────────────────────────
class _FeatureProgressRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int done, total;
  final Color color;
  const _FeatureProgressRow({
    required this.icon,
    required this.label,
    required this.done,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return Row(
      children: [
        Icon(icon, color: color, size: 10),
        const SizedBox(width: 4),
        Text(
          '$label $done/$total',
          style: TextStyle(
            color: color.withOpacity(0.8),
            fontSize: 8.5,
            fontFamily: 'Orbitron',
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 4,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

// ── _DeleteConfirmDialog ────────────────────────────────────
class _DeleteConfirmDialog extends StatelessWidget {
  final Animation<double> pulseAnim;
  const _DeleteConfirmDialog({required this.pulseAnim});

  static const _red = Color(0xFFFF2D55);
  static const _cyan = Color(0xFF00E5FF);
  static const _bg = Color(0xFF0D0D0D);

  Future<void> _doDelete(BuildContext context) async {
    // Reset profil dan progression
    await ProfileService.instance.reset();
    await ProgressionService.instance.resetProgress();

    if (!context.mounted) return;

    // Tutup dialog, lalu replace seluruh stack ke ProfileSetupPage
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const ProfileSetupPage(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: child,
        ),
      ),
      (route) => false, // hapus semua route di stack
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: AnimatedBuilder(
        animation: pulseAnim,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _red.withOpacity(0.3 + 0.15 * pulseAnim.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _red.withOpacity(0.08 + 0.06 * pulseAnim.value),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon peringatan
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _red.withOpacity(0.08),
                    border: Border.all(
                      color: _red.withOpacity(0.35 + 0.2 * pulseAnim.value),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _red.withOpacity(0.15 + 0.1 * pulseAnim.value),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: _red,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 20),

                // Judul
                const Text(
                  'Hapus Akun?',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 12),

                // Keterangan
                const Text(
                  'Hapus akun dan mulai dari awal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: _red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Semua data profil, XP, level, dan progress akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: Colors.white38,
                    fontSize: 10,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 28),

                // Tombol aksi
                Row(
                  children: [
                    // Batal
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white.withOpacity(0.05),
                            border: Border.all(color: Colors.white12, width: 1),
                          ),
                          child: const Center(
                            child: Text(
                              'BATAL',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Hapus
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _doDelete(context),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                _red.withOpacity(0.85),
                                const Color(0xFFBB0033).withOpacity(0.85),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _red.withOpacity(
                                  0.25 + 0.15 * pulseAnim.value,
                                ),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'HAPUS',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Data classes ─────────────────────────────────────────────
class _StatData {
  final IconData icon;
  final String label, value;
  final Color color;
  const _StatData(this.icon, this.label, this.value, this.color);
}

class _DiffData {
  final String name, subtitle;
  final Color color;
  final int startLevel, endLevel;
  const _DiffData(
    this.name,
    this.color,
    this.subtitle,
    this.startLevel,
    this.endLevel,
  );
}
