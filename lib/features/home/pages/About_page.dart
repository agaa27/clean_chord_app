import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
//  CONSTANTS
// ─────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0A0A0A);
  static const cyan = Color(0xFF00FFFF);
  static const purple = Color(0xFFBD00FF);
  static const surface = Color(0xFF111118);
  static const border = Color(0xFF1E1E2E);
}

// ─────────────────────────────────────────────
//  ABOUT PAGE
// ─────────────────────────────────────────────
class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  // Staggered fade-in
  late List<Animation<double>> _fadeAnims;

  @override
  void initState() {
    super.initState();

    // Ambient pulse (slow, subtle)
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulse = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);

    // Staggered entrance animations driven by _pulseCtrl's first pass
    // We use a single forward animation for entry
    _fadeAnims = List.generate(7, (i) {
      return CurvedAnimation(
        parent: _pulseCtrl,
        curve: Interval(i * 0.04, math.min(1.0, i * 0.04 + 0.5),
            curve: Curves.easeOut),
      );
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: _C.bg,
        body: AnimatedBuilder(
          animation: _pulse,
          builder: (context, _) => _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),
              _buildProfileSection(),
              const SizedBox(height: 28),
              _buildAboutCard(),
              const SizedBox(height: 16),
              _buildFeaturesCard(),
              const SizedBox(height: 16),
              _buildTechStackCard(),
              const SizedBox(height: 16),
              _buildContactCard(),
              const SizedBox(height: 16),
              _buildVersionBadge(),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  // ── APP BAR ──────────────────────────────────
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.maybePop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        color: _C.cyan,
      ),
      title: ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [_C.cyan, _C.purple],
        ).createShader(bounds),
        child: const Text(
          'ABOUT',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 4,
            color: Colors.white,
          ),
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                _C.cyan.withOpacity(0.4 + 0.2 * _pulse.value),
                _C.purple.withOpacity(0.4 + 0.2 * _pulse.value),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── PROFILE SECTION ──────────────────────────
  Widget _buildProfileSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        // Avatar with glow rings
        _GlowingAvatar(pulse: _pulse.value),
        const SizedBox(height: 20),
        // Name
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_C.cyan, _C.purple],
          ).createShader(bounds),
          child: const Text(
            'RANGGA SAPUTRA',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Role
        Text(
          'Flutter Developer  •  Clean Chord App',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 10,
            color: _C.cyan.withOpacity(0.75),
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Quote bubble
        _QuoteWidget(pulse: _pulse.value),
      ],
    );
  }

  // ── ABOUT CARD ───────────────────────────────
  Widget _buildAboutCard() {
    return _NeonCard(
      pulse: _pulse.value,
      accentColor: _C.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.info_outline_rounded,
            label: 'TENTANG APLIKASI',
            color: _C.cyan,
          ),
          const SizedBox(height: 12),
          Text(
            'Aplikasi pembelajaran gitar interaktif berbasis Flutter '
            'untuk membantu pengguna mempelajari chord gitar secara '
            'visual dan praktik.',
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              color: Colors.white.withOpacity(0.72),
              height: 1.8,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── FEATURES CARD ────────────────────────────
  Widget _buildFeaturesCard() {
    const features = [
      (Icons.quiz_outlined, 'Quiz Chord', _C.cyan),
      (Icons.image_outlined, 'Gambar Chord', _C.purple),
      (Icons.av_timer, 'Metronome', _C.cyan),
      (Icons.library_music_outlined, 'Chord Library', _C.purple),
    ];

    return _NeonCard(
      pulse: _pulse.value,
      accentColor: _C.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.star_outline_rounded,
            label: 'FITUR APLIKASI',
            color: _C.purple,
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 3.2,
            children: features
                .map((f) => _FeatureChip(
                      icon: f.$1,
                      label: f.$2,
                      color: f.$3,
                      pulse: _pulse.value,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── TECH STACK CARD ──────────────────────────
  Widget _buildTechStackCard() {
    const stack = [
      ('Flutter', Icons.flutter_dash),
      ('Dart', Icons.code_rounded),
      ('Custom Painter', Icons.draw_outlined),
      ('SharedPreferences', Icons.storage_outlined),
    ];

    return _NeonCard(
      pulse: _pulse.value,
      accentColor: _C.cyan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.developer_mode_rounded,
            label: 'TECH STACK',
            color: _C.cyan,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: stack
                .map((s) => _TechBadge(
                      label: s.$1,
                      icon: s.$2,
                      pulse: _pulse.value,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── CONTACT CARD ─────────────────────────────
  Widget _buildContactCard() {
    const contacts = [
      (Icons.camera_alt_outlined, 'Instagram', '@ranggasaputraaaa_'),
      (Icons.code_rounded, 'GitHub', 'github.com/agaa27'),
      (Icons.email_outlined, 'Email', 'ranggasaputra@gmail.com'),
    ];

    return _NeonCard(
      pulse: _pulse.value,
      accentColor: _C.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(
            icon: Icons.connect_without_contact_rounded,
            label: 'KONTAK',
            color: _C.purple,
          ),
          const SizedBox(height: 12),
          ...contacts.map(
            (c) => _ContactRow(
              icon: c.$1,
              platform: c.$2,
              handle: c.$3,
              pulse: _pulse.value,
            ),
          ),
        ],
      ),
    );
  }

  // ── VERSION BADGE ────────────────────────────
  Widget _buildVersionBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _C.cyan.withOpacity(0.25 + 0.15 * _pulse.value),
          ),
          gradient: LinearGradient(
            colors: [
              _C.cyan.withOpacity(0.06),
              _C.purple.withOpacity(0.06),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: _C.cyan.withOpacity(0.08 + 0.06 * _pulse.value),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified_rounded,
                size: 14, color: _C.cyan.withOpacity(0.8)),
            const SizedBox(width: 8),
            Text(
              'v1.0',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                color: _C.cyan.withOpacity(0.9),
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────

/// Glowing circular avatar with animated rings
class _GlowingAvatar extends StatelessWidget {
  final double pulse;
  const _GlowingAvatar({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          Container(
            width: 116,
            height: 116,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _C.cyan.withOpacity(0.15 + 0.12 * pulse),
                  blurRadius: 24 + 8 * pulse,
                  spreadRadius: 4 + 3 * pulse,
                ),
                BoxShadow(
                  color: _C.purple.withOpacity(0.12 + 0.10 * pulse),
                  blurRadius: 32 + 8 * pulse,
                  spreadRadius: 2 + 2 * pulse,
                ),
              ],
              gradient: SweepGradient(
                colors: [
                  _C.cyan.withOpacity(0.6),
                  _C.purple.withOpacity(0.6),
                  _C.cyan.withOpacity(0.6),
                ],
              ),
            ),
          ),

          // Inner dark ring (gap)
          Container(
            width: 108,
            height: 108,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _C.bg,
            ),
          ),

          // Avatar circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF0D0D1A),
                ],
              ),
              border: Border.all(
                color: _C.cyan.withOpacity(0.3),
                width: 1,
              ),
            ),

            // FOTO PROFILE
            child: ClipOval(
              child: Image.asset(
                'assets/images/Ranggas.jpeg',
                fit: BoxFit.cover,
                width: 100,
                height: 100,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassmorphism card with neon border glow
class _NeonCard extends StatelessWidget {
  final Widget child;
  final double pulse;
  final Color accentColor;

  const _NeonCard({
    required this.child,
    required this.pulse,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _C.surface,
        border: Border.all(
          color: accentColor.withOpacity(0.18 + 0.10 * pulse),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.06 + 0.04 * pulse),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Section header with icon and neon label
class _CardHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CardHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.5), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Feature chip for grid
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double pulse;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withOpacity(0.07),
        border: Border.all(
          color: color.withOpacity(0.22 + 0.08 * pulse),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 9,
                color: Colors.white.withOpacity(0.85),
                letterSpacing: 0.4,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tech stack pill badge
class _TechBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final double pulse;

  const _TechBadge({
    required this.label,
    required this.icon,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _C.cyan.withOpacity(0.08),
            _C.purple.withOpacity(0.08),
          ],
        ),
        border: Border.all(
          color: _C.cyan.withOpacity(0.20 + 0.08 * pulse),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _C.cyan.withOpacity(0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 9,
              color: Colors.white.withOpacity(0.80),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Contact row item
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String platform;
  final String handle;
  final double pulse;

  const _ContactRow({
    required this.icon,
    required this.platform,
    required this.handle,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _C.purple.withOpacity(0.10),
              border: Border.all(
                color: _C.purple.withOpacity(0.25 + 0.10 * pulse),
                width: 1,
              ),
            ),
            child: Icon(icon, size: 16, color: _C.purple),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                platform.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 9,
                  color: _C.purple.withOpacity(0.8),
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                handle,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.75),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Italic quote with neon left border
class _QuoteWidget extends StatelessWidget {
  final double pulse;
  const _QuoteWidget({required this.pulse});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _C.cyan.withOpacity(0.05),
        border: Border(
          left: BorderSide(
            color: _C.cyan.withOpacity(0.55 + 0.25 * pulse),
            width: 2.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.format_quote_rounded,
              size: 18, color: _C.cyan.withOpacity(0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '"Belajar gitar interaktif dengan visual modern."',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 10,
                color: Colors.white.withOpacity(0.65),
                fontStyle: FontStyle.italic,
                letterSpacing: 0.4,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}