import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../pustaka_chord/data/chord_library.dart';
import '../../pustaka_chord/models/chord_model.dart';
import '../../pustaka_chord/models/chord_shape_model.dart';
import '../../pustaka_chord/widgets/chord_fretboard_widget.dart';
import '../models/gambar_level_model.dart';
import '../widgets/interactive_fretboard_widget.dart';
import '../../kuis_chord/widgets/kuis_progress_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Konversi nama chord (sama dengan kuis_chord)
// ─────────────────────────────────────────────────────────────────────────────
String _formatChordName(ChordModel c) {
  if (c.type == 'major') return c.root;
  if (c.type == 'minor') return '${c.root}m';
  return '${c.root}${c.type}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Tuning standar — open string notes (semitone, C=0)
// index: 0=low E, 1=A, 2=D, 3=G, 4=B, 5=high e
// ─────────────────────────────────────────────────────────────────────────────
const List<int> _openStringNotes = [4, 9, 2, 7, 11, 4]; // E A D G B E
const List<String> _noteNames = [
  'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'
];

// Konversi (string, fret absolut) → nama nada
String _fretToNote(int stringIdx, int fret) {
  return _noteNames[(_openStringNotes[stringIdx] + fret) % 12];
}

// ─────────────────────────────────────────────────────────────────────────────
// Set nada per jenis chord — dipakai untuk validasi bebas posisi
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, List<int>> _chordIntervals = {
  'major': [0, 4, 7],
  'minor': [0, 3, 7],
  '7':     [0, 4, 7, 10],
  'maj7':  [0, 4, 7, 11],
  'm7':    [0, 3, 7, 10],
  'sus4':  [0, 5, 7],
  'add9':  [0, 2, 4, 7],
  '5':     [0, 7],
};

int _noteIndex(String note) => _noteNames.indexOf(note);

/// Kembalikan set nada (string) yang membentuk chord ini
Set<String> _chordNoteSet(ChordModel chord) {
  final intervals = _chordIntervals[chord.type];
  if (intervals == null) return {};
  final root = _noteIndex(chord.root);
  return intervals
      .map((i) => _noteNames[(root + i) % 12])
      .toSet();
}

// ─────────────────────────────────────────────────────────────────────────────
// Validasi jawaban user — BEBAS POSISI
//
// Aturan:
//  1. Setiap string tidak-mute & ada dot → hasilkan 1 nada
//  2. Kumpulkan semua nada unik yang dihasilkan user
//  3. Benar jika:
//     • Semua nada dalam chordNoteSet ada di userNotes
//     • Semua userNotes ada di chordNoteSet (tidak ada nada asing)
//     • Minimal ada dot (tidak boleh kosong semua)
// ─────────────────────────────────────────────────────────────────────────────
bool _validateAnswer({
  required ChordModel chord,
  required List<FingerPosition> userDots,
  required List<bool> userMuted,
}) {
  if (userDots.isEmpty) return false;

  final chordNotes = _chordNoteSet(chord);
  if (chordNotes.isEmpty) return false;

  final userNotes = <String>{};
  for (final dot in userDots) {
    if (userMuted[dot.string]) continue;
    userNotes.add(_fretToNote(dot.string, dot.fret));
  }

  if (userNotes.isEmpty) return false;

  // Semua nada chord harus ada, tidak boleh ada nada di luar chord
  return userNotes.containsAll(chordNotes) &&
      chordNotes.containsAll(userNotes);
}

// ─────────────────────────────────────────────────────────────────────────────
// Warna review per string:
//   hijau = nada di string ini termasuk chord
//   merah = nada asing / di string yang harusnya tidak ada nada
// ─────────────────────────────────────────────────────────────────────────────
Map<int, Color> _buildReviewColors({
  required ChordModel chord,
  required List<FingerPosition> userDots,
}) {
  final chordNotes = _chordNoteSet(chord);
  final result = <int, Color>{};
  for (final dot in userDots) {
    final note = _fretToNote(dot.string, dot.fret);
    result[dot.string] = chordNotes.contains(note)
        ? const Color(0xFF00E676)
        : const Color(0xFFFF4C4C);
  }
  return result;
}

// ─────────────────────────────────────────────────────────────────────────────

class GambarChordGamePage extends StatefulWidget {
  final GambarLevel level;
  const GambarChordGamePage({super.key, required this.level});

  @override
  State<GambarChordGamePage> createState() => _GambarChordGamePageState();
}

class _GambarChordGamePageState extends State<GambarChordGamePage>
    with TickerProviderStateMixin {

  // ── State ─────────────────────────────────────────────────────────────────
  int _score           = 0;
  int _currentQuestion = 0;
  late int _timeLeft;
  Timer? _timer;

  ChordModel? _currentChord;
  List<FingerPosition> _userDots  = [];
  List<bool> _userMuted           = List.filled(6, false);
  bool _showIntro                 = true;
  bool _isReviewing               = false;
  bool _isCorrect                 = false;
  bool _isGameOver                = false;
  bool _dialogShown               = false;
  bool _showAnswerPanel           = false; // panel lihat jawaban referensi
  final Random _random            = Random();

  // ── Animasi ───────────────────────────────────────────────────────────────
  late AnimationController _questionAnim;
  late Animation<double>   _questionFade;
  late AnimationController _resultAnim;
  late Animation<double>   _resultScale;

  // ── Palette ───────────────────────────────────────────────────────────────
  static const Color _bg      = Color(0xFF070A0F);
  static const Color _card    = Color(0xFF0D1520);
  static const Color _cyan    = Color(0xFF00E5FF);
  static const Color _purple  = Color(0xFFBD00FF);
  static const Color _orange  = Color(0xFFFFAA00);
  static const Color _correct = Color(0xFF00E676);
  static const Color _wrong   = Color(0xFFFF4C4C);

  Color get _accent {
    switch (widget.level.difficulty) {
      case 'Pemula':   return _cyan;
      case 'Menengah': return _purple;
      case 'Mahir':    return _orange;
      default:         return _cyan;
    }
  }

  int get _initialDuration =>
      gambarDurationForDifficulty(widget.level.difficulty);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _timeLeft = _initialDuration;

    _questionAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _questionFade = CurvedAnimation(
        parent: _questionAnim, curve: Curves.easeIn);

    _resultAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _resultScale = CurvedAnimation(
        parent: _resultAnim, curve: Curves.elasticOut);

    _generateQuestion();
    _questionAnim.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _questionAnim.dispose();
    _resultAnim.dispose();
    super.dispose();
  }

  // ── Game flow ─────────────────────────────────────────────────────────────
  void _startGame() {
    setState(() {
      _showIntro   = false;
      _dialogShown = false;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = _initialDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        t.cancel();
        if (!_isGameOver) {
          setState(() => _isGameOver = true);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showEndDialog();
          });
        }
      }
    });
  }

  List<ChordModel> get _validChords => chordLibrary
      .where((c) => widget.level.chordNames.contains(_formatChordName(c)))
      .toList();

  void _generateQuestion() {
    final valid = _validChords;
    if (valid.isEmpty) return;
    setState(() {
      _currentChord    = valid[_random.nextInt(valid.length)];
      _userDots        = [];
      _userMuted       = List.filled(6, false);
      _isReviewing     = false;
      _isCorrect       = false;
      _showAnswerPanel = false;
    });
    _questionAnim.reset();
    _questionAnim.forward();
  }

  // ── Interaksi fretboard ───────────────────────────────────────────────────
  void _onTapFret(int string, int fret) {
    if (_isReviewing || _isGameOver) return;
    setState(() {
      final existing = _userDots.indexWhere((d) => d.string == string);
      if (existing != -1) {
        if (_userDots[existing].fret == fret) {
          // Tap posisi sama → hapus
          _userDots = List.from(_userDots)..removeAt(existing);
        } else {
          // Tap posisi beda → pindah
          _userDots = List.from(_userDots)
            ..[existing] = FingerPosition(string: string, fret: fret);
        }
      } else {
        if (_userDots.length < 6) {
          _userDots   = [..._userDots, FingerPosition(string: string, fret: fret)];
          _userMuted  = List.from(_userMuted)..[string] = false;
        }
      }
    });
  }

  void _onToggleMute(int string) {
    if (_isReviewing || _isGameOver) return;
    HapticFeedback.selectionClick();
    setState(() {
      _userMuted = List.from(_userMuted)..[string] = !_userMuted[string];
      if (_userMuted[string]) {
        _userDots = _userDots.where((d) => d.string != string).toList();
      }
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _submitAnswer() {
    if (_isReviewing || _currentChord == null) return;
    _timer?.cancel();

    final correct = _validateAnswer(
      chord:    _currentChord!,
      userDots: _userDots,
      userMuted: _userMuted,
    );

    correct
        ? HapticFeedback.lightImpact()
        : HapticFeedback.heavyImpact();

    setState(() {
      _isReviewing = true;
      _isCorrect   = correct;
      if (correct) _score++;
    });

    _resultAnim.reset();
    _resultAnim.forward();

    // Lanjut soal berikutnya setelah 2.5 detik
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted || _isGameOver) return;
      _currentQuestion++;
      if (_currentQuestion >= widget.level.targetPoints) {
        _showWinDialog();
      } else {
        _generateQuestion();
        _startTimer();
      }
    });
  }

  // ── Reset ─────────────────────────────────────────────────────────────────
  void _resetGame() {
    setState(() {
      _score           = 0;
      _currentQuestion = 0;
      _timeLeft        = _initialDuration;
      _isGameOver      = false;
      _dialogShown     = false;
      _isReviewing     = false;
      _isCorrect       = false;
      _userDots        = [];
      _userMuted       = List.filled(6, false);
      _showAnswerPanel = false;
    });
    _generateQuestion();
    _startTimer();
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showWinDialog() {
    if (!mounted || _dialogShown) return;
    _dialogShown = true;
    _timer?.cancel();
    _showResultDialog(
      icon: '🎸',
      title: 'Selesai!',
      titleColor: _correct,
      message: 'Kamu menjawab benar $_score dari ${widget.level.targetPoints} soal.',
      actions: [
        _dialogBtn(
          label: 'Selesai',
          color: _accent,
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _showEndDialog() {
    if (!mounted || _dialogShown) return;
    _dialogShown = true;
    _showResultDialog(
      icon: '⏱',
      title: 'Waktu Habis!',
      titleColor: _wrong,
      message: 'Soal ${_currentQuestion + 1} / ${widget.level.targetPoints}\nBenar: $_score soal.',
      actions: [
        _dialogBtn(
          label: 'Coba Lagi',
          color: _accent,
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            _resetGame();
          },
        ),
        _dialogBtn(
          label: 'Keluar',
          color: Colors.white38,
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.of(context).pop();
          },
        ),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1520),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                  color: titleColor.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                    color: titleColor.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 2),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 12),
                Text(title,
                    style: TextStyle(
                        color: titleColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5)),
                const SizedBox(height: 22),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dialogBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(23)),
            ),
            onPressed: onTap,
            child: Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 14)),
          ),
        ),
      );

  // ─────────────────────────────── BUILD ───────────────────────────────────
  @override
  Widget build(BuildContext context) =>
      _showIntro ? _buildIntroScreen() : _buildGameScreen();

  // ─────────────────────── INTRO SCREEN ────────────────────────────────────
  Widget _buildIntroScreen() {
    final accent = _accent;
    final previewChords = widget.level.chordNames
        .take(6)
        .map((name) {
          try {
            return chordLibrary
                .firstWhere((c) => _formatChordName(c) == name);
          } catch (_) {
            return null;
          }
        })
        .whereType<ChordModel>()
        .toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white38, size: 18),
                  ),
                  Text(
                    'Level ${widget.level.id}  •  ${widget.level.name}',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: accent.withValues(alpha: 0.3)),
                    ),
                    child: Text(widget.level.difficulty,
                        style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
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
                  border: Border.all(
                      color: accent.withValues(alpha: 0.4), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                        color: accent.withValues(alpha: 0.1),
                        blurRadius: 30)
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      'CHORD YANG AKAN DIUJI  •  ${widget.level.chordNames.length} CHORD',
                      style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.level.targetPoints} soal  •  ${_initialDuration}s per soal',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                    // Petunjuk
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: accent.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: accent, size: 14),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Tap fret untuk pasang dot • Tap lagi di posisi sama untuk hapus • Tap tombol senar (E A D G B e) untuk mute • Posisi bebas, asal menghasilkan nada chord yang benar',
                              style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Preview chord — pakai ChordFretboardWidget asli
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        child: GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: previewChords.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemBuilder: (ctx, i) {
                            final chord = previewChords[i];
                            final name  = _formatChordName(chord);
                            return Container(
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color:
                                        accent.withValues(alpha: 0.1)),
                              ),
                              padding:
                                  const EdgeInsets.fromLTRB(4, 10, 4, 6),
                              child: Column(
                                children: [
                                  Text(name,
                                      style: TextStyle(
                                          color: accent,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
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
                      padding:
                          const EdgeInsets.fromLTRB(16, 10, 16, 18),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                accent.withValues(alpha: 0.12),
                            foregroundColor: accent,
                            side: BorderSide(color: accent, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                            elevation: 0,
                          ),
                          onPressed: _startGame,
                          child: const Text('MULAI',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3)),
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
    final accent  = _accent;
    final timeLow = _timeLeft <= (_initialDuration ~/ 5);
    final reviewColors = _isReviewing && _currentChord != null
        ? _buildReviewColors(chord: _currentChord!, userDots: _userDots)
        : <int, Color>{};

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ── Top bar ─────────────────────────────────────────────────
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
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white54, size: 15),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level ${widget.level.id}  •  Soal ${_currentQuestion + 1} / ${widget.level.targetPoints}',
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        KuisProgressBar(
                          currentPoints: _score,
                          targetPoints:  widget.level.targetPoints,
                          accentColor:   accent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
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
                              : Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_rounded,
                            color: timeLow ? _wrong : Colors.white70,
                            size: 14),
                        const SizedBox(width: 5),
                        Text('${_timeLeft}s',
                            style: TextStyle(
                                color: timeLow ? _wrong : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ── Label soal ──────────────────────────────────────────────
            if (_currentChord != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20),
                  decoration: BoxDecoration(
                    color: _isReviewing
                        ? (_isCorrect
                            ? _correct.withValues(alpha: 0.08)
                            : _wrong.withValues(alpha: 0.08))
                        : accent.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isReviewing
                          ? (_isCorrect
                              ? _correct.withValues(alpha: 0.5)
                              : _wrong.withValues(alpha: 0.5))
                          : accent.withValues(alpha: 0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Gambar chord ',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 14)),
                      Text(
                        _formatChordName(_currentChord!),
                        style: TextStyle(
                          color: _isReviewing
                              ? (_isCorrect ? _correct : _wrong)
                              : accent,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      // Nada-nada chord (hint)
                      if (!_isReviewing && _currentChord != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          _chordNoteSet(_currentChord!).join(' '),
                          style: TextStyle(
                              color: accent.withValues(alpha: 0.45),
                              fontSize: 11),
                        ),
                      ],
                      if (_isReviewing) ...[
                        const SizedBox(width: 10),
                        ScaleTransition(
                          scale: _resultScale,
                          child: Icon(
                            _isCorrect
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: _isCorrect ? _correct : _wrong,
                            size: 24,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 8),

            // ── Fretboard + panel jawaban referensi ─────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeTransition(
                  opacity: _questionFade,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: accent.withValues(alpha: 0.12)),
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
                    child: Column(
                      children: [
                        // Tombol mute per string
                        _buildMuteRow(accent),
                        const SizedBox(height: 4),

                        // Fretboard interaktif
                        Expanded(
                          child: InteractiveFretboardWidget(
                            placedDots:   _userDots,
                            mutedStrings: _userMuted,
                            onTap:        _onTapFret,
                            onToggleMute: _onToggleMute,
                            reviewMode:   _isReviewing,
                            reviewColors: reviewColors,
                            baseFret: 1,
                          ),
                        ),

                        // Panel referensi jawaban (setelah salah)
                        if (_isReviewing && !_isCorrect && _currentChord != null)
                          _buildReferencePanel(accent),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Tombol bawah ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  // Reset
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color:
                                  Colors.white.withValues(alpha: 0.15)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: _isReviewing
                            ? null
                            : () => setState(() {
                                  _userDots  = [];
                                  _userMuted = List.filled(6, false);
                                }),
                        icon: const Icon(Icons.refresh_rounded,
                            size: 16, color: Colors.white38),
                        label: const Text('Reset',
                            style: TextStyle(
                                color: Colors.white38, fontSize: 13)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Submit
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReviewing
                              ? Colors.white.withValues(alpha: 0.05)
                              : accent.withValues(alpha: 0.15),
                          foregroundColor:
                              _isReviewing ? Colors.white38 : accent,
                          side: BorderSide(
                            color: _isReviewing
                                ? Colors.white.withValues(alpha: 0.1)
                                : accent,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24)),
                          elevation: 0,
                        ),
                        onPressed: _isReviewing ? null : _submitAnswer,
                        child: Text(
                          _isReviewing ? 'Menilai...' : 'SELESAI',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Baris tombol mute senar ───────────────────────────────────────────────
  Widget _buildMuteRow(Color accent) {
    const labels = ['E', 'A', 'D', 'G', 'B', 'e'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (i) {
          final isMuted = _userMuted[i];
          return GestureDetector(
            onTap: () => _onToggleMute(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 28,
              decoration: BoxDecoration(
                color: isMuted
                    ? _wrong.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isMuted
                      ? _wrong.withValues(alpha: 0.5)
                      : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Center(
                child: Text(
                  isMuted ? '✕' : labels[i],
                  style: TextStyle(
                    color: isMuted ? _wrong : Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Panel referensi jawaban benar (tampil saat salah) ─────────────────────
  Widget _buildReferencePanel(Color accent) {
    final chord  = _currentChord!;
    final shape  = chord.shapes.first;
    final notes  = _chordNoteSet(chord);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      decoration: BoxDecoration(
        color: _wrong.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _wrong.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Header toggle
          InkWell(
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14)),
            onTap: () =>
                setState(() => _showAnswerPanel = !_showAnswerPanel),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded,
                      color: _wrong, size: 14),
                  const SizedBox(width: 8),
                  Text('Nada: ${notes.join('  ')}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11)),
                  const Spacer(),
                  Text(
                    _showAnswerPanel
                        ? 'Sembunyikan contoh'
                        : 'Lihat contoh posisi',
                    style: TextStyle(color: _wrong, fontSize: 11),
                  ),
                  Icon(
                    _showAnswerPanel
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: _wrong,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),

          // Panel ChordFretboardWidget (collapse)
          if (_showAnswerPanel)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                height: 160,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: ChordFretboardWidget(
                    shape: shape,
                    chordName: _formatChordName(chord),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
