import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../pustaka_chord/data/chord_library.dart';
import '../../pustaka_chord/models/chord_model.dart';
import '../../pustaka_chord/widgets/chord_fretboard_widget.dart';
import '../models/quiz_level_model.dart';
import '../../../core/services/quiz_audio_service.dart';
import '../widgets/kuis_progress_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper — konversi ChordModel → nama tampil
// major  → root (e.g. 'C')
// minor  → root + 'm' (e.g. 'Am')
// lainnya → root + type (e.g. 'C7', 'Cmaj7', 'Csus4')
// ─────────────────────────────────────────────────────────────────────────────
String formatChordName(ChordModel c) {
  if (c.type == 'major') return c.root;
  if (c.type == 'minor') return '${c.root}m';
  return '${c.root}${c.type}';
}

class KuisChordGamePage extends StatefulWidget {
  final QuizLevel level;
  const KuisChordGamePage({super.key, required this.level});

  @override
  State<KuisChordGamePage> createState() => _KuisChordGamePageState();
}

class _KuisChordGamePageState extends State<KuisChordGamePage>
    with TickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  int _points   = 0;
  int _streak   = 0;
  late int _timeLeft;
  int _shapeIndex = 0;
  Timer? _timer;
  ChordModel? _currentChord;
  List<String> _options = [];
  bool _isGameOver    = false;
  bool _showIntro     = true;
  bool _dialogShowing = false;
  String? _selectedAnswer;
  final Random _random = Random();

  // ── Audio ─────────────────────────────────────────────────────────────────
  final QuizAudioService _audio = QuizAudioService();

  // ── Animation controllers ─────────────────────────────────────────────────
  late AnimationController _questionAnim;
  late Animation<double>   _questionFade;
  late AnimationController _streakAnim;
  late Animation<double>   _streakScale;

  // ── Palette ───────────────────────────────────────────────────────────────
  static const Color _bg      = Color(0xFF070A0F);
  static const Color _card    = Color(0xFF0D1520);
  static const Color _cyan    = Color(0xFF00E5FF);
  static const Color _purple  = Color(0xFFBD00FF);
  static const Color _orange  = Color(0xFFFFAA00);
  static const Color _correct = Color(0xFF00E676);
  static const Color _wrong   = Color(0xFFFF4C4C);

  Color get _accentColor {
    switch (widget.level.difficulty) {
      case 'Pemula':   return _cyan;
      case 'Menengah': return _purple;
      case 'Mahir':    return _orange;
      default:         return _cyan;
    }
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _timeLeft = widget.level.timeLimitSeconds;

    _questionAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _questionFade = CurvedAnimation(
      parent: _questionAnim,
      curve: Curves.easeIn,
    );
    _streakAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _streakScale = CurvedAnimation(
      parent: _streakAnim,
      curve: Curves.elasticOut,
    );

    // Init audio di background — tidak blocking UI
    _audio.init();

    _generateQuestion();
    _questionAnim.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionAnim.dispose();
    _streakAnim.dispose();
    _audio.dispose(); // bersihkan semua AudioPlayer
    super.dispose();
  }

  // ── Game flow ─────────────────────────────────────────────────────────────
  void _startGame() {
    setState(() => _showIntro = false);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        t.cancel();
        if (!_isGameOver) {
          setState(() => _isGameOver = true);
          // Suara gagal — sebelum dialog muncul
          _audio.playFail();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showEndDialog();
          });
        }
      }
    });
  }

  void _restartGame() {
    _timer?.cancel();
    setState(() {
      _points         = 0;
      _streak         = 0;
      _timeLeft       = widget.level.timeLimitSeconds;
      _isGameOver     = false;
      _dialogShowing  = false;
      _selectedAnswer = null;
      _showIntro      = false;
    });
    _generateQuestion();
    _questionAnim.reset();
    _questionAnim.forward();
    _startTimer();
  }

  void _exitGame() {
    _timer?.cancel();
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  List<ChordModel> get _validChords => chordLibrary
      .where((c) => widget.level.chordNames.contains(formatChordName(c)))
      .toList();

  void _generateQuestion() {
    // FIX: guard race condition — timer habis saat Future.delayed 750ms masih pending
    if (_isGameOver) return;
    final valid = _validChords;
    if (valid.isEmpty) return;

    _currentChord = valid[_random.nextInt(valid.length)];
    _shapeIndex   = 0;

    final correctName = formatChordName(_currentChord!);
    final allNames    = widget.level.chordNames.toList();
    allNames.remove(correctName);
    allNames.shuffle(_random);

    final opts = <String>[correctName];
    for (final n in allNames) {
      if (opts.length >= 4) break;
      opts.add(n);
    }
    if (opts.length < 4) {
      final extras = chordLibrary
          .map(formatChordName)
          .where((n) => !opts.contains(n))
          .toList()
        ..shuffle(_random);
      for (final e in extras) {
        if (opts.length >= 4) break;
        opts.add(e);
      }
    }
    opts.shuffle(_random);

    setState(() {
      _options        = opts;
      _selectedAnswer = null;
    });
    _questionAnim.reset();
    _questionAnim.forward();
  }

  void _checkAnswer(String selected) {
    if (_isGameOver || _selectedAnswer != null) return;
    final correct   = formatChordName(_currentChord!);
    final isCorrect = selected == correct;

    // Haptic + suara jawaban — berjalan bersamaan
    if (isCorrect) {
      HapticFeedback.lightImpact();
      _audio.playCorrect();
    } else {
      HapticFeedback.heavyImpact();
      _audio.playWrong();
    }

    setState(() {
      _selectedAnswer = selected;
      if (isCorrect) {
        _points++;
        _streak++;
        _streakAnim
          ..reset()
          ..forward();
      } else {
        if (_points > 0) _points--;
        _streak = 0;
      }
    });

    // Win condition
    if (_points >= widget.level.targetPoints) {
      _timer?.cancel();
      // Suara win setelah suara correct selesai (~0.4–0.5 detik)
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _audio.playWin();
      });
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && !_dialogShowing) _showWinDialog();
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 750), () {
      if (mounted && !_isGameOver) _generateQuestion();
    });
  }

  // ── Button colour helpers ─────────────────────────────────────────────────
  Color _btnBg(String option) {
    if (_selectedAnswer == null) return _card;
    final c = formatChordName(_currentChord!);
    if (option == c)               return _correct.withValues(alpha: 0.15);
    if (option == _selectedAnswer) return _wrong.withValues(alpha: 0.15);
    return _card;
  }

  Color _btnBorder(String option) {
    if (_selectedAnswer == null) return Colors.white.withValues(alpha: 0.1);
    final c = formatChordName(_currentChord!);
    if (option == c)               return _correct;
    if (option == _selectedAnswer) return _wrong;
    return Colors.white.withValues(alpha: 0.05);
  }

  Color _btnText(String option) {
    if (_selectedAnswer == null) return Colors.white;
    final c = formatChordName(_currentChord!);
    if (option == c)               return _correct;
    if (option == _selectedAnswer) return _wrong;
    return Colors.white30;
  }

  IconData? _btnIcon(String option) {
    if (_selectedAnswer == null) return null;
    final c = formatChordName(_currentChord!);
    if (option == c)               return Icons.check_circle_rounded;
    if (option == _selectedAnswer) return Icons.cancel_rounded;
    return null;
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showWinDialog() {
    if (!mounted || _dialogShowing) return;
    _dialogShowing = true;
    _showResultDialog(
      icon: '🎸',
      title: 'Luar Biasa!',
      titleColor: _correct,
      message: 'Level ${widget.level.id} selesai!\nSkor: $_points / ${widget.level.targetPoints}',
      actions: [
        _dialogAction('Selesai', _accentColor, () {
          Navigator.of(context, rootNavigator: false).pop();
          _exitGame();
        }),
      ],
    );
  }

  void _showEndDialog() {
    if (!mounted || _dialogShowing) return;
    _dialogShowing = true;
    _showResultDialog(
      icon: '⏱',
      title: 'Waktu Habis!',
      titleColor: _wrong,
      message: 'Skor kamu: $_points / ${widget.level.targetPoints}',
      actions: [
        _dialogAction('Coba Lagi', _accentColor, () {
          Navigator.of(context, rootNavigator: false).pop();
          _restartGame();
        }),
        _dialogAction('Keluar', Colors.white38, () {
          Navigator.of(context, rootNavigator: false).pop();
          _exitGame();
        }),
      ],
    );
  }

  void _showResultDialog({
    required String icon,
    required String title,
    required Color titleColor,
    required String message,
    required List<Widget> actions,
  }) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          // FIX: bungkus dengan ConstrainedBox agar dialog tidak overflow
          // di device kecil, lalu SingleChildScrollView agar konten scrollable
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1520),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: titleColor.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: titleColor.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 44)),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    ...actions,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _dialogShowing = false);
    });
  }

  Widget _dialogAction(String label, Color color, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(23),
              ),
            ),
            onPressed: onTap,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                fontSize: 14,
              ),
            ),
          ),
        ),
      );

  // ─────────────────────────────── BUILD ───────────────────────────────────
  @override
  Widget build(BuildContext context) =>
      _showIntro ? _buildIntroScreen() : _buildGameScreen();

  // ─────────────────────── INTRO SCREEN ────────────────────────────────────
  Widget _buildIntroScreen() {
    final previewNames = widget.level.chordNames.toList();
    final previewChords = previewNames
        .map((name) {
          try {
            return chordLibrary.firstWhere(
              (c) => formatChordName(c) == name,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<ChordModel>()
        .toList();

    final accent = _accentColor;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white38,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Level ${widget.level.id}  •  ${widget.level.name}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      widget.level.difficulty,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                decoration: BoxDecoration(
                  color: _bg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 30),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      'PELAJARI CHORD  •  ${previewChords.length} CHORD',
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Target: ${widget.level.targetPoints} poin  •  ${widget.level.timeLimitSeconds} detik',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    const SizedBox(height: 14),

                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: previewChords.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.82,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (context, i) {
                            final chord = previewChords[i];
                            final name  = formatChordName(chord);
                            return Container(
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: accent.withValues(alpha: 0.1)),
                              ),
                              padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
                              child: Column(
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Expanded(
                                    child: ClipRect(
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: ChordFretboardWidget(
                                          shape: chord.shapes.first,
                                          chordName: '',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent.withValues(alpha: 0.12),
                            foregroundColor: accent,
                            side: BorderSide(color: accent, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _startGame,
                          child: const Text(
                            'MULAI KUIS',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── GAME SCREEN ─────────────────────────────────
  Widget _buildGameScreen() {
    final accent = _accentColor;
    final int lowThreshold =
        (widget.level.timeLimitSeconds / 4).round().clamp(8, 15);
    final bool timeLow = _timeLeft <= lowThreshold;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white54,
                        size: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${widget.level.id}  •  ${widget.level.name}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        KuisProgressBar(
                          currentPoints: _points,
                          targetPoints: widget.level.targetPoints,
                          accentColor: accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Mute toggle ──────────────────────────────────────────
                  GestureDetector(
                    onTap: () => setState(() => _audio.toggleMute()),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Icon(
                        _audio.isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: _audio.isMuted
                            ? Colors.white24
                            : Colors.white54,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Timer badge
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: timeLow
                          ? _wrong.withValues(alpha: 0.12)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: timeLow
                            ? _wrong.withValues(alpha: 0.5)
                            : Colors.white12,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_rounded,
                          color: timeLow ? _wrong : Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${_timeLeft}s',
                          style: TextStyle(
                            color: timeLow ? _wrong : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Question label ─────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'CHORD APAKAH INI?',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3,
                  ),
                ),
                if (_streak >= 3) ...[
                  const SizedBox(width: 10),
                  ScaleTransition(
                    scale: _streakScale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _orange.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.local_fire_department_rounded,
                              color: _orange, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '×$_streak',
                            style: const TextStyle(
                              color: _orange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // ── Fretboard ─────────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _questionFade,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: accent.withValues(alpha: 0.12)),
                    ),
                    child: _currentChord != null
                        ? FittedBox(
                            fit: BoxFit.contain,
                            child: ChordFretboardWidget(
                              shape: _currentChord!.shapes[_shapeIndex],
                              chordName: '?',
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Answer options ─────────────────────────────────────────────
            if (_options.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3.2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, i) {
                    final opt  = _options[i];
                    final icon = _btnIcon(opt);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      decoration: BoxDecoration(
                        color: _btnBg(opt),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: _btnBorder(opt), width: 1.5),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => _checkAnswer(opt),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: _btnText(opt), size: 16),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              opt,
                              style: TextStyle(
                                color: _btnText(opt),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
