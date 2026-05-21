import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'time_signature_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MetronomePage
// ─────────────────────────────────────────────────────────────────────────────
class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

class _MetronomePageState extends State<MetronomePage>
    with TickerProviderStateMixin {
  // ── State ──────────────────────────────────────────
  int _bpm = 120;
  static const int _minBpm = 30;
  static const int _maxBpm = 240;

  bool _isPlaying = false;
  int _currentBeat = 0;
  String _timeSignature = '4/4';

  // ── Timer ──────────────────────────────────────────
  Timer? _ticker;

  // ── Audio ──────────────────────────────────────────
  // Dua player terpisah: accent (beat 1) dan normal.
  // Source di-set sekali di initState → tidak buat decoder baru tiap beat.
  final AudioPlayer _accentPlayer = AudioPlayer();
  final AudioPlayer _normalPlayer = AudioPlayer();
  bool _audioReady = false;

  // ── Animations ─────────────────────────────────────
  late AnimationController _pendulumController;
  late AnimationController _pulseController;
  late AnimationController _beatFlashController;
  late Animation<double> _pulseAnim;
  late Animation<double> _beatFlashAnim;

  // ── Dial drag ──────────────────────────────────────
  Offset? _lastDragAngle;

  // ── Tap tempo ──────────────────────────────────────
  final List<int> _tapTimes = [];

  @override
  void initState() {
    super.initState();

    _pendulumController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (60000 / _bpm).round()),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _beatFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _beatFlashAnim = CurvedAnimation(
      parent: _beatFlashController,
      curve: Curves.easeOut,
    );

    _initAudio();
  }

  // Pre-load audio sekali — tidak di-reload tiap beat
  Future<void> _initAudio() async {
    try {
      await _accentPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _normalPlayer.setPlayerMode(PlayerMode.lowLatency);

      await _accentPlayer.setReleaseMode(ReleaseMode.stop);
      await _normalPlayer.setReleaseMode(ReleaseMode.stop);

      await _accentPlayer.setVolume(1.0);
      await _normalPlayer.setVolume(0.45);

      // setSource sekali → decoder dibuat sekali, resume() berikutnya cepat
      await _accentPlayer.setSource(AssetSource('audio/Metronome.mp3'));
      await _normalPlayer.setSource(AssetSource('audio/Metronome.mp3'));

      if (mounted) setState(() => _audioReady = true);
    } catch (_) {
      // Audio gagal tersedia — metronome tetap jalan tanpa suara
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _accentPlayer.dispose();
    _normalPlayer.dispose();
    _pendulumController.dispose();
    _pulseController.dispose();
    _beatFlashController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────
  int get _beatsPerMeasure {
    final parts = _timeSignature.split('/');
    return int.tryParse(parts[0]) ?? 4;
  }

  Duration get _beatInterval => Duration(milliseconds: (60000 / _bpm).round());

  void _setBpm(int bpm) {
    setState(() => _bpm = bpm.clamp(_minBpm, _maxBpm));
    if (_isPlaying) {
      _restartTicker();
      _pendulumController.duration = Duration(
        milliseconds: (60000 / _bpm).round(),
      );
    }
  }

  void _togglePlay() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _currentBeat = 0;
        _startTicker();
      } else {
        _stopTicker();
      }
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _pendulumController.duration = _beatInterval;
    _pendulumController.repeat(reverse: true);
    _ticker = Timer.periodic(_beatInterval, (_) => _onBeat());
    _onBeat(); // langsung beat pertama
  }

  void _restartTicker() {
    _ticker?.cancel();
    _pendulumController.duration = _beatInterval;
    _pendulumController.repeat(reverse: true);
    _ticker = Timer.periodic(_beatInterval, (_) => _onBeat());
  }

  // resume() jauh lebih ringan daripada play(AssetSource(...))
  // karena tidak membuat MediaCodec baru tiap beat
  Future<void> _playTick(bool isAccent) async {
    if (!_audioReady) return;
    try {
      if (isAccent) {
        await _accentPlayer.stop();
        await _accentPlayer.resume();
      } else {
        await _normalPlayer.stop();
        await _normalPlayer.resume();
      }
    } catch (_) {}
  }

  void _onBeat() {
    if (!mounted) return;

    final nextBeat = (_currentBeat % _beatsPerMeasure) + 1;
    final isAccent = nextBeat == 1;

    _playTick(isAccent);

    if (isAccent) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.selectionClick();
    }

    _beatFlashController.forward(from: 0);
    setState(() {
      _currentBeat = nextBeat;
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
    _pendulumController.stop();
    _pendulumController.reset();
    setState(() => _currentBeat = 0);
  }

  // ── Tap Tempo ──────────────────────────────────────
  void _handleTapTempo() {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (_tapTimes.isNotEmpty && now - _tapTimes.last > 2000) {
      _tapTimes.clear();
    }

    _tapTimes.add(now);
    if (_tapTimes.length > 8) _tapTimes.removeAt(0);

    if (_tapTimes.length >= 2) {
      final gaps = <int>[];
      for (int i = 1; i < _tapTimes.length; i++) {
        gaps.add(_tapTimes[i] - _tapTimes[i - 1]);
      }
      final avgGap = gaps.reduce((a, b) => a + b) / gaps.length;
      final newBpm = (60000 / avgGap).round();
      _setBpm(newBpm);
    }
    HapticFeedback.lightImpact();
  }

  // ── Dial drag logic ────────────────────────────────
  void _onDialDragStart(DragStartDetails details, Offset center) {
    final localPos = details.localPosition - center;
    _lastDragAngle = localPos;
  }

  void _onDialDragUpdate(DragUpdateDetails details, Offset center) {
    if (_lastDragAngle == null) return;
    final newAngle = details.localPosition - center;
    final cross =
        _lastDragAngle!.dx * newAngle.dy - _lastDragAngle!.dy * newAngle.dx;
    final delta = cross > 0 ? 1 : -1;
    _setBpm(_bpm + delta);
    _lastDragAngle = newAngle;
  }

  // ── Navigate to time signature ─────────────────────
  Future<void> _openTimeSignature() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => TimeSignaturePage(selected: _timeSignature),
      ),
    );
    if (result != null && mounted) {
      setState(() => _timeSignature = result);
      if (_isPlaying) {
        _stopTicker();
        _startTicker();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Icon(Icons.av_timer, color: const Color(0xFF9D00FF), size: 20),
            const SizedBox(width: 8),
            const Text(
              'Metronom',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) => Container(
              height: 1,
              color: const Color(
                0xFF9D00FF,
              ).withOpacity(0.2 + 0.15 * _pulseAnim.value),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildBpmDisplay(),
            const SizedBox(height: 8),
            Expanded(child: _buildDial()),
            _buildBeatIndicators(),
            const SizedBox(height: 20),
            _buildTapTempoButton(),
            const SizedBox(height: 16),
            _buildTimeSignatureButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── BPM Display ────────────────────────────────────
  Widget _buildBpmDisplay() {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BpmButton(
              icon: Icons.remove,
              onTap: () => _setBpm(_bpm - 1),
              onLongPress: () => _setBpm(_bpm - 5),
              color: const Color(0xFF9D00FF),
            ),
            const SizedBox(width: 24),
            Column(
              children: [
                AnimatedBuilder(
                  animation: _beatFlashAnim,
                  builder: (context, _) {
                    final flash = _beatFlashAnim.value;
                    return ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          Color.lerp(
                            Colors.white,
                            const Color(0xFF9D00FF),
                            flash,
                          )!,
                          Color.lerp(Colors.white70, Colors.cyanAccent, flash)!,
                        ],
                      ).createShader(bounds),
                      child: Text(
                        '$_bpm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -2,
                          shadows: [
                            Shadow(
                              color: const Color(
                                0xFF9D00FF,
                              ).withOpacity(0.4 + 0.4 * flash),
                              blurRadius: 20 + 10 * flash,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Text(
                  'Ketukan per menit',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            _BpmButton(
              icon: Icons.add,
              onTap: () => _setBpm(_bpm + 1),
              onLongPress: () => _setBpm(_bpm + 5),
              color: const Color(0xFF9D00FF),
            ),
          ],
        );
      },
    );
  }

  // ── Circular Dial ──────────────────────────────────
  Widget _buildDial() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.88;
        final center = Offset(size / 2, size / 2);

        return Center(
          child: GestureDetector(
            onPanStart: (d) => _onDialDragStart(d, center),
            onPanUpdate: (d) => _onDialDragUpdate(d, center),
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, _) => CustomPaint(
                      size: Size(size, size),
                      painter: _DialPainter(
                        bpm: _bpm,
                        minBpm: _minBpm,
                        maxBpm: _maxBpm,
                        pulseValue: _pulseAnim.value,
                        isPlaying: _isPlaying,
                      ),
                    ),
                  ),

                  if (_isPlaying)
                    AnimatedBuilder(
                      animation: _pendulumController,
                      builder: (context, _) {
                        final angle =
                            (_pendulumController.value * 2 - 1) *
                            math.pi *
                            0.35;
                        return Transform.rotate(
                          angle: angle,
                          child: Container(
                            width: 2,
                            height: size * 0.32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  const Color(0xFF9D00FF).withOpacity(0.9),
                                  const Color(0xFF9D00FF).withOpacity(0.0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        );
                      },
                    ),

                  AnimatedBuilder(
                    animation: _beatFlashAnim,
                    builder: (context, _) {
                      final flash = _beatFlashAnim.value;
                      return GestureDetector(
                        onTap: _togglePlay,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isPlaying
                                ? const Color(0xFF9D00FF).withOpacity(0.15)
                                : Colors.black,
                            border: Border.all(
                              color: Color.lerp(
                                const Color(0xFF9D00FF).withOpacity(0.6),
                                Colors.cyanAccent,
                                _isPlaying ? flash : 0,
                              )!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF9D00FF).withOpacity(
                                  _isPlaying ? 0.3 + 0.3 * flash : 0.1,
                                ),
                                blurRadius: _isPlaying ? 24 + 12 * flash : 8,
                                spreadRadius: _isPlaying ? 2 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.stop_rounded
                                : Icons.play_arrow_rounded,
                            color: _isPlaying
                                ? Colors.cyanAccent
                                : const Color(0xFF9D00FF),
                            size: 36,
                          ),
                        ),
                      );
                    },
                  ),

                  Positioned(
                    top: size * 0.12,
                    child: Text(
                      _tempoLabel(_bpm),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  Positioned(
                    left:
                        size * 0.5 +
                        (size * 0.36) * math.cos(math.pi * 0.7) -
                        8,
                    top:
                        size * 0.5 +
                        (size * 0.36) * math.sin(math.pi * 0.7) -
                        8,
                    child: _dialLabel('30'),
                  ),
                  Positioned(
                    left:
                        size * 0.5 +
                        (size * 0.36) *
                            math.cos(math.pi * 0.7 + math.pi * 1.6 * 35 / 210) -
                        8,
                    top:
                        size * 0.5 +
                        (size * 0.36) *
                            math.sin(math.pi * 0.7 + math.pi * 1.6 * 35 / 210) -
                        8,
                    child: _dialLabel('65'),
                  ),
                  Positioned(
                    left:
                        size * 0.5 +
                        (size * 0.36) *
                            math.cos(
                              math.pi * 0.7 + math.pi * 1.6 * 175 / 210,
                            ) -
                        8,
                    top:
                        size * 0.5 +
                        (size * 0.36) *
                            math.sin(
                              math.pi * 0.7 + math.pi * 1.6 * 175 / 210,
                            ) -
                        8,
                    child: _dialLabel('205'),
                  ),
                  Positioned(
                    left:
                        size * 0.5 +
                        (size * 0.36) * math.cos(math.pi * 2.3) -
                        8,
                    top:
                        size * 0.5 +
                        (size * 0.36) * math.sin(math.pi * 2.3) -
                        8,
                    child: _dialLabel('240'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dialLabel(String text) => Text(
    text,
    style: TextStyle(
      color: Colors.white.withOpacity(0.3),
      fontSize: 11,
      letterSpacing: 0.5,
    ),
  );

  String _tempoLabel(int bpm) {
    if (bpm < 60) return 'Largo';
    if (bpm < 66) return 'Larghetto';
    if (bpm < 76) return 'Adagio';
    if (bpm < 108) return 'Andante';
    if (bpm < 120) return 'Moderato';
    if (bpm < 156) return 'Allegro';
    if (bpm < 176) return 'Vivace';
    if (bpm < 200) return 'Presto';
    return 'Prestissimo';
  }

  // ── Beat Indicators ────────────────────────────────
  Widget _buildBeatIndicators() {
    final beats = _beatsPerMeasure;
    return AnimatedBuilder(
      animation: _beatFlashAnim,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(beats, (i) {
            final beatNum = i + 1;
            final isActive = _isPlaying && _currentBeat == beatNum;
            final isAccent = beatNum == 1;

            final dotColor = isAccent
                ? const Color(0xFF9D00FF)
                : const Color(0xFF00FFFF);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              width: isActive ? (isAccent ? 16 : 12) : (isAccent ? 10 : 8),
              height: isActive ? (isAccent ? 16 : 12) : (isAccent ? 10 : 8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? dotColor : dotColor.withOpacity(0.2),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: dotColor.withOpacity(0.7),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        );
      },
    );
  }

  // ── Tap Tempo Button ───────────────────────────────
  Widget _buildTapTempoButton() {
    return GestureDetector(
      onTap: _handleTapTempo,
      child: AnimatedBuilder(
        animation: _pulseAnim,
        builder: (context, _) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.cyanAccent.withOpacity(
                  0.3 + 0.2 * _pulseAnim.value,
                ),
                width: 1,
              ),
              color: Colors.cyanAccent.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(
                    0.05 + 0.05 * _pulseAnim.value,
                  ),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  color: Colors.cyanAccent.withOpacity(0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap Tempo',
                  style: TextStyle(
                    color: Colors.cyanAccent.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Time Signature Button ──────────────────────────
  Widget _buildTimeSignatureButton() {
    return GestureDetector(
      onTap: _openTimeSignature,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, _) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(
                      0xFF9D00FF,
                    ).withOpacity(0.45 + 0.3 * _pulseAnim.value),
                    width: 1.5,
                  ),
                  color: const Color(0xFF9D00FF).withOpacity(0.08),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF9D00FF,
                      ).withOpacity(0.1 + 0.08 * _pulseAnim.value),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Text(
                  _timeSignature,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Tanda birama',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tombol BPM +/-
// ─────────────────────────────────────────────────────────────────────────────
class _BpmButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Color color;

  const _BpmButton({
    required this.icon,
    required this.onTap,
    required this.onLongPress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          color: color.withOpacity(0.08),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.15), blurRadius: 12),
          ],
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dial Painter
// ─────────────────────────────────────────────────────────────────────────────
class _DialPainter extends CustomPainter {
  final int bpm;
  final int minBpm;
  final int maxBpm;
  final double pulseValue;
  final bool isPlaying;

  const _DialPainter({
    required this.bpm,
    required this.minBpm,
    required this.maxBpm,
    required this.pulseValue,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    const totalTicks = 120;
    const startAngle = math.pi * 0.7;
    const sweepAngle = math.pi * 1.6;

    for (int i = 0; i <= totalTicks; i++) {
      final angle = startAngle + (sweepAngle * i / totalTicks);
      final isMajor = i % 10 == 0;
      final tickLen = isMajor ? 12.0 : 6.0;
      final outer = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - tickLen) * math.cos(angle),
        center.dy + (radius - tickLen) * math.sin(angle),
      );

      final progress = i / totalTicks;
      final bpmProgress = (bpm - minBpm) / (maxBpm - minBpm);
      final isActive = progress <= bpmProgress;

      canvas.drawLine(
        inner,
        outer,
        Paint()
          ..color = isActive
              ? const Color(0xFF9D00FF).withOpacity(0.6 + 0.3 * pulseValue)
              : Colors.white.withOpacity(0.12)
          ..strokeWidth = isMajor ? 2 : 1
          ..strokeCap = StrokeCap.round,
      );
    }

    final bpmProgress = (bpm - minBpm) / (maxBpm - minBpm);
    final progressSweep = sweepAngle * bpmProgress;
    final safeSweep = progressSweep < 0.001 ? 0.001 : progressSweep;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + safeSweep,
        colors: [
          const Color(0xFF9D00FF).withOpacity(0.4),
          const Color(0xFF9D00FF),
          Colors.cyanAccent,
        ],
        stops: const [0.0, 0.7, 1.0],
        transform: GradientRotation(startAngle),
      ).createShader(Rect.fromCircle(center: center, radius: radius - 3));

    if (progressSweep > 0.001) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 3),
        startAngle,
        progressSweep,
        false,
        arcPaint,
      );
    }

    final knobAngle = startAngle + progressSweep;
    final knobPos = Offset(
      center.dx + (radius - 3) * math.cos(knobAngle),
      center.dy + (radius - 3) * math.sin(knobAngle),
    );

    canvas.drawCircle(
      knobPos,
      14,
      Paint()
        ..color = const Color(0xFF9D00FF).withOpacity(0.2 + 0.15 * pulseValue)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawCircle(
      knobPos,
      10,
      Paint()
        ..color = const Color(0xFF9D00FF).withOpacity(0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(knobPos, 8, Paint()..color = const Color(0xFF1A1A2E));
    canvas.drawCircle(
      knobPos,
      3,
      Paint()..color = Colors.cyanAccent.withOpacity(0.9),
    );
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.bpm != bpm ||
      old.pulseValue != pulseValue ||
      old.isPlaying != isPlaying;
}
