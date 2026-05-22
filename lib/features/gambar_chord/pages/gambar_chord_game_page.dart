import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../pustaka_chord/data/chord_library.dart';
import '../../pustaka_chord/models/chord_model.dart';
import '../../pustaka_chord/widgets/chord_fretboard_widget.dart';
import '../models/gambar_level_model.dart';
import '../services/quiz_audio_service.dart';
import '../widgets/interactive_fretboard_widget.dart';
import '../../../core/chord/models/finger_position.dart';
import '../../kuis_chord/widgets/kuis_progress_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helper nama chord
// ─────────────────────────────────────────────────────────────────────────────
String _fmtChord(ChordModel c) {
  if (c.type == 'major') return c.root;
  if (c.type == 'minor') return '${c.root}m';
  return '${c.root}${c.type}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Tuning standar gitar — semitone dari C=0
// index: 0=low E  1=A  2=D  3=G  4=B  5=high e
// ─────────────────────────────────────────────────────────────────────────────
const _openSemitones = [4, 9, 2, 7, 11, 4]; // E A D G B E
const _noteNames = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];

/// Nada dari senar [s] ditekan di [fret]. fret=0 → open string.
String _note(int s, int fret) => _noteNames[(_openSemitones[s] + fret) % 12];

// ─────────────────────────────────────────────────────────────────────────────
// Interval per tipe chord (semitone dari root)
// ─────────────────────────────────────────────────────────────────────────────
const _chordIntervals = <String, List<int>>{
  'major': [0, 4, 7],
  'minor': [0, 3, 7],
  '7':     [0, 4, 7, 10],
  'maj7':  [0, 4, 7, 11],
  'm7':    [0, 3, 7, 10],
  'sus4':  [0, 5, 7],
  'add9':  [0, 2, 4, 7],
  '5':     [0, 7],
};

Set<String> _chordNotes(ChordModel c) {
  final iv   = _chordIntervals[c.type];
  if (iv == null) return {};
  final root = _noteNames.indexOf(c.root);
  if (root == -1) return {};
  return iv.map((i) => _noteNames[(root + i) % 12]).toSet();
}

// ─────────────────────────────────────────────────────────────────────────────
// VALIDASI — TOLERAN & BENAR UNTUK SEMUA CHORD TERMASUK BARRE
//
// Masalah dengan exact-match sebelumnya:
//   User yang tidak mute string open yang "tidak sengaja" berbunyi
//   akan selalu gagal, padahal penempatan dotnya sudah benar.
//
// Logika baru (dua tahap):
//
// TAHAP 1 — Kumpulkan nada dari DOT yang user taruh saja:
//   dotNotes = { _note(string, fret) untuk setiap dot }
//
// TAHAP 2 — Cek coverage:
//   Jawaban BENAR jika dotNotes mencakup SEMUA nada chord target.
//   (Subset check: target ⊆ dotNotes)
//
//   Open string yang tidak di-mute DIABAIKAN dalam validasi —
//   user tidak perlu mute secara eksplisit.
//   Hanya dot yang dipasang user yang dievaluasi.
//
// Dengan ini:
//   • C major (C E G): user pasang 3 dot yang menghasilkan C, E, G → BENAR ✓
//   • Bm barre: user pasang dot di string 1-5 sesuai barre,
//     string 0 open E dibiarkan → TETAP BENAR karena hanya dot yang dihitung ✓
//   • Tidak bisa curang dengan pasang 1 dot saja karena semua nada chord harus ada ✓
// ─────────────────────────────────────────────────────────────────────────────
bool _validate({
  required ChordModel chord,
  required List<FingerPosition> dots,
  required List<bool> muted,
}) {
  final target = _chordNotes(chord);
  if (target.isEmpty) return false;

  // Kumpulkan semua nada yang terdengar:
  // 1. Nada dari dot yang dipasang (fret > 0, string tidak di-mute)
  // 2. Nada open string yang tidak di-mute DAN tidak punya dot
  //    (open string yang ada dotnya tidak dihitung sebagai open)
  final playedNotes = <String>{};

  final stringWithDot = dots.map((d) => d.string).toSet();

  // Dot notes
  for (final d in dots) {
    if (!muted[d.string]) {
      playedNotes.add(_note(d.string, d.fret));
    }
  }

  // Open string notes (hanya string tanpa dot dan tidak di-mute)
  for (int s = 0; s < 6; s++) {
    if (!muted[s] && !stringWithDot.contains(s)) {
      playedNotes.add(_note(s, 0));
    }
  }

  if (playedNotes.isEmpty) return false;

  // Semua nada chord harus tercakup — extra note tidak masalah
  return target.every((n) => playedNotes.contains(n));
}

// ─────────────────────────────────────────────────────────────────────────────
// Warna review per string
// Hijau  = nada string ini adalah bagian dari chord
// Merah  = nada asing (bukan bagian chord)
// Hanya string yang ada dot yang diberi warna
// ─────────────────────────────────────────────────────────────────────────────
Map<int, Color> _buildReviewColors({
  required ChordModel chord,
  required List<FingerPosition> dots,
  required List<bool> muted,
}) {
  final target = _chordNotes(chord);
  final result = <int, Color>{};

  for (final d in dots) {
    if (muted[d.string]) continue;
    final ok  = target.contains(_note(d.string, d.fret));
    result[d.string] = ok ? const Color(0xFF00E676) : const Color(0xFFFF4C4C);
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

  // ── Game state ────────────────────────────────────────────────────────────
  int  _score            = 0;
  int  _questionIdx      = 0;
  int  _timeLeft         = 0;
  bool _showIntro        = true;
  bool _isReviewing      = false;
  bool _isCorrect        = false;
  bool _isGameOver       = false;
  bool _dialogShown      = false;
  bool _showAnswerPanel  = false;
  // Flag agar Future.delayed dan skip tidak race condition
  bool _reviewCompleted  = false;

  // ── Fretboard state ───────────────────────────────────────────────────────
  ChordModel?          _chord;
  List<FingerPosition> _dots  = [];
  List<bool>           _muted = List.filled(6, false);
  int                  _baseFret = 1;

  Timer?       _timer;
  final Random _rng = Random();

  // ── Audio ─────────────────────────────────────────────────────────────────
  final QuizAudioService _audio = QuizAudioService();

  // ── Animasi ───────────────────────────────────────────────────────────────
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;
  late AnimationController _resultCtrl;
  late Animation<double>   _resultAnim;

  // ── Palette ───────────────────────────────────────────────────────────────
  static const _bg     = Color(0xFF070A0F);
  static const _card   = Color(0xFF0D1520);
  static const _cyan   = Color(0xFF00E5FF);
  static const _purple = Color(0xFFBD00FF);
  static const _orange = Color(0xFFFFAA00);
  static const _green  = Color(0xFF00E676);
  static const _red    = Color(0xFFFF4C4C);

  Color get _accent => switch (widget.level.difficulty) {
    'Pemula'   => _cyan,
    'Menengah' => _purple,
    'Mahir'    => _orange,
    _          => _cyan,
  };

  int get _duration => gambarDurationForDifficulty(widget.level.difficulty);

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _resultCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _resultAnim = CurvedAnimation(
        parent: _resultCtrl, curve: Curves.elasticOut);
    _audio.init();
    _pickQuestion();
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeCtrl.dispose();
    _resultCtrl.dispose();
    _audio.dispose();
    super.dispose();
  }

  // ── Game flow ─────────────────────────────────────────────────────────────
  void _startGame() {
    setState(() {
      _showIntro   = false;
      _dialogShown = false;
      _timeLeft    = _duration; // set sekali di sini — timer global, tidak reset per soal
    });
    _startTimer();
  }

  // _startTimer hanya membuat/mengganti periodic ticker.
  // Ia TIDAK mereset _timeLeft — itu tugas _startGame dan _reset.
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      if (_isReviewing) return; // timer pause saat review
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        t.cancel();
        if (!_isGameOver) {
          setState(() => _isGameOver = true);
          _audio.playFail();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showEndDialog();
          });
        }
      }
    });
  }

  List<ChordModel> get _pool => chordLibrary
      .where((c) => widget.level.chordNames.contains(_fmtChord(c)))
      .toList();

  void _pickQuestion() {
    final pool = _pool;
    if (pool.isEmpty) return;
    setState(() {
      _chord           = pool[_rng.nextInt(pool.length)];
      _dots            = [];
      _muted           = List.filled(6, false);
      _baseFret        = 1;
      _isReviewing     = false;
      _isCorrect       = false;
      _showAnswerPanel = false;
    });
    _fadeCtrl.reset();
    _fadeCtrl.forward();
  }

  // ── Navigasi baseFret untuk chord barre ───────────────────────────────────
  void _shiftBase(int delta) {
    if (_isReviewing || _isGameOver) return;
    final next = (_baseFret + delta).clamp(1, 17);
    if (next == _baseFret) return;
    // FIX: filter pakai 'next', bukan _baseFret — setState synchronous jadi
    // _baseFret sudah = next saat where() dieksekusi → dot salah hilang.
    setState(() {
      _dots = _dots
          .where((d) => d.fret >= next && d.fret < next + 5)
          .toList();
      _baseFret = next;
    });
  }
  //
  // Aturan tap:
  //   • Tap sel yang sudah ada dot → HAPUS dot itu (toggle off)
  //   • Tap sel kosong di string yang sudah ada dot → GESER dot ke fret baru
  //   • Tap sel kosong di string yang belum ada dot → TAMBAH dot baru
  //
  // Dengan ini barre chord bisa dibentuk: user tap string 1..5 di fret 2 → 5 dot terpasang ✓
  void _onTap(int string, int fret) {
    if (_isReviewing || _isGameOver) return;
    setState(() {
      final exactIdx = _dots.indexWhere(
        (d) => d.string == string && d.fret == fret,
      );
      if (exactIdx != -1) {
        // Tap di posisi yang persis sama → hapus dot
        _dots = List.from(_dots)..removeAt(exactIdx);
      } else {
        // Hapus dot lama di string yang sama (kalau ada) lalu pasang di fret baru
        _dots = _dots.where((d) => d.string != string).toList();
        _dots = [..._dots, FingerPosition(string: string, fret: fret, finger: 0)];
        _muted = List.from(_muted)..[string] = false;
      }
    });
  }

  void _toggleMute(int string) {
    if (_isReviewing || _isGameOver) return;
    HapticFeedback.selectionClick();
    setState(() {
      _muted = List.from(_muted)..[string] = !_muted[string];
      if (_muted[string]) {
        _dots = _dots.where((d) => d.string != string).toList();
      }
    });
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _submit() {
    if (_isReviewing || _chord == null) return;
    // FIX: JANGAN cancel timer global di sini — timer countdown harus terus jalan.
    // Timer hanya di-cancel saat game over / reset / exit.

    final ok = _validate(chord: _chord!, dots: _dots, muted: _muted);

    if (ok) {
      HapticFeedback.lightImpact();
      _audio.playCorrect();
    } else {
      HapticFeedback.heavyImpact();
      _audio.playWrong();
    }

    // FIX: set _reviewCompleted = false SEBELUM setState agar
    // tidak ada window di mana flag belum di-reset tapi Future sudah terjadwal.
    _reviewCompleted = false;
    setState(() {
      _isReviewing = true;
      _isCorrect   = ok;
      if (ok) _score++;
    });
    _resultCtrl.reset();
    _resultCtrl.forward();

    final delay = ok
        ? const Duration(milliseconds: 2000)
        : const Duration(milliseconds: 9000);

    Future.delayed(delay, () {
      if (!mounted || _isGameOver || _reviewCompleted) return;
      _nextQuestion();
    });
  }

  // ── Skip review (jawaban salah) ───────────────────────────────────────────
  void _skipReview() {
    if (!_isReviewing || _isCorrect || _reviewCompleted) return;
    // FIX: set flag LANGSUNG (bukan dalam setState) agar Future.delayed
    // membaca nilai terbaru secara synchronous sebelum callback terjadwal.
    _reviewCompleted = true;
    _nextQuestion();
  }

  // ── Pindah soal ───────────────────────────────────────────────────────────
  void _nextQuestion() {
    // FIX: guard ganda — pastikan tidak dipanggil dua kali
    if (!mounted || _isGameOver) return;
    _questionIdx++;
    if (_questionIdx >= widget.level.targetPoints) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _audio.playWin();
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted && !_dialogShown) _showWinDialog();
      });
    } else {
      _pickQuestion();
    }
  }

  // ── Reset / Exit ──────────────────────────────────────────────────────────
  void _reset() {
    _timer?.cancel();
    setState(() {
      _score            = 0;
      _questionIdx      = 0;
      _timeLeft         = _duration;
      _isGameOver       = false;
      _dialogShown      = false;
      _isReviewing      = false;
      _isCorrect        = false;
      _reviewCompleted  = false;
      _dots             = [];
      _muted            = List.filled(6, false);
      _baseFret         = 1;
      _showAnswerPanel  = false;
    });
    _pickQuestion();
    _startTimer(); // boleh restart saat full reset
  }

  void _exit() {
    _timer?.cancel();
    if (mounted && Navigator.canPop(context)) Navigator.pop(context);
  }

  // ── Dialogs ───────────────────────────────────────────────────────────────
  void _showWinDialog() {
    if (!mounted || _dialogShown) return;
    _dialogShown = true;
    _timer?.cancel();
    _showResultDialog(
      icon: '🎸', title: 'Selesai!', titleColor: _green,
      message: 'Kamu menjawab benar $_score dari ${widget.level.targetPoints} soal.',
      actions: [
        _dialogBtn('Selesai', _accent, () {
          Navigator.of(context, rootNavigator: false).pop();
          _exit();
        }),
      ],
    );
  }

  void _showEndDialog() {
    if (!mounted || _dialogShown) return;
    _dialogShown = true;
    _showResultDialog(
      icon: '⏱', title: 'Waktu Habis!', titleColor: _red,
      message: 'Soal ${_questionIdx + 1} / ${widget.level.targetPoints}\nBenar: $_score soal.',
      actions: [
        _dialogBtn('Coba Lagi', _accent, () {
          Navigator.of(context, rootNavigator: false).pop();
          _reset();
        }),
        _dialogBtn('Keluar', Colors.white38, () {
          Navigator.of(context, rootNavigator: false).pop();
          _exit();
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
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: titleColor.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [BoxShadow(
                  color: titleColor.withValues(alpha: 0.15),
                  blurRadius: 30, spreadRadius: 2)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 44)),
                const SizedBox(height: 12),
                Text(title, style: TextStyle(
                    color: titleColor, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.5)),
                const SizedBox(height: 22),
                ...actions,
              ],
            ),
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _dialogShown = false);
    });
  }

  Widget _dialogBtn(String label, Color color, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity, height: 46,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: color.withValues(alpha: 0.6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
            ),
            onPressed: onTap,
            child: Text(label, style: TextStyle(
                color: color, fontWeight: FontWeight.bold,
                letterSpacing: 1, fontSize: 14)),
          ),
        ),
      );

  // ═══════════════════════════════ BUILD ════════════════════════════════════
  @override
  Widget build(BuildContext context) =>
      _showIntro ? _buildIntro() : _buildGame();

  // ─────────────────────────── INTRO ───────────────────────────────────────
  Widget _buildIntro() {
    final accent   = _accent;
    final previews = widget.level.chordNames.take(6)
        .map((n) {
          try { return chordLibrary.firstWhere((c) => _fmtChord(c) == n); }
          catch (_) { return null; }
        })
        .whereType<ChordModel>()
        .toList();

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white38, size: 18),
              ),
              Text('Level ${widget.level.id}  •  ${widget.level.name}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14,
                      fontWeight: FontWeight.w600)),
              _diffBadge(accent),
            ],
          ),
        ),

        Expanded(child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.1), blurRadius: 30)],
          ),
          child: Column(children: [
            const SizedBox(height: 18),
            Text(
              'CHORD YANG AKAN DIUJI  •  ${widget.level.chordNames.length} CHORD',
              style: TextStyle(color: accent, fontSize: 12,
                  fontWeight: FontWeight.w800, letterSpacing: 2),
            ),
            const SizedBox(height: 6),
            Text('${widget.level.targetPoints} soal  •  ${_duration}s per soal',
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 10),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: accent, size: 14),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tap fret → pasang dot  •  Tap lagi di posisi sama → hapus  •  '
                      'Tap nama senar (E A D G B e) → mute  •  '
                      '▲▼ di samping fretboard → geser posisi untuk chord barre  •  '
                      'Pasang dot di semua nada chord — urutan bebas',
                      style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: previews.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 0.85,
                  crossAxisSpacing: 8, mainAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  final c = previews[i];
                  return Container(
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: accent.withValues(alpha: 0.1)),
                    ),
                    padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
                    child: Column(children: [
                      Text(_fmtChord(c), style: TextStyle(
                          color: accent, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Expanded(child: ClipRect(child: FittedBox(
                        fit: BoxFit.contain,
                        child: ChordFretboardWidget(shape: c.shapes.first, chordName: ''),
                      ))),
                    ]),
                  );
                },
              ),
            )),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              child: SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent.withValues(alpha: 0.12),
                    foregroundColor: accent,
                    side: BorderSide(color: accent, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 0,
                  ),
                  onPressed: _startGame,
                  child: const Text('MULAI', style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 3)),
                ),
              ),
            ),
          ]),
        )),
        const SizedBox(height: 16),
      ])),
    );
  }

  // ─────────────────────────── GAME ────────────────────────────────────────
  Widget _buildGame() {
    final accent    = _accent;
    final timeLow   = _timeLeft <= (_duration ~/ 5).clamp(5, 12);
    final revColors = _isReviewing && _chord != null
        ? _buildReviewColors(chord: _chord!, dots: _dots, muted: _muted)
        : <int, Color>{};

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: Column(children: [
        const SizedBox(height: 10),

        // ── Top bar ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white54, size: 15),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Soal ${_questionIdx + 1} / ${widget.level.targetPoints}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                KuisProgressBar(
                  currentPoints: _score,
                  targetPoints:  widget.level.targetPoints,
                  accentColor:   accent,
                ),
              ],
            )),
            const SizedBox(width: 8),

            // Mute audio toggle
            GestureDetector(
              onTap: () => setState(() => _audio.toggleMute()),
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.white12),
                ),
                child: Icon(
                  _audio.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: _audio.isMuted ? Colors.white24 : Colors.white54,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Timer badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: timeLow
                    ? _red.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: timeLow ? _red.withValues(alpha: 0.5) : Colors.white12),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.timer_rounded,
                    color: timeLow ? _red : Colors.white70, size: 14),
                const SizedBox(width: 5),
                Text('${_timeLeft}s', style: TextStyle(
                    color: timeLow ? _red : Colors.white,
                    fontSize: 14, fontWeight: FontWeight.bold)),
              ]),
            ),
          ]),
        ),

        const SizedBox(height: 12),

        // ── Label soal ───────────────────────────────────────────────────
        if (_chord != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              decoration: BoxDecoration(
                color: _isReviewing
                    ? (_isCorrect ? _green.withValues(alpha: 0.08) : _red.withValues(alpha: 0.08))
                    : accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isReviewing
                      ? (_isCorrect ? _green.withValues(alpha: 0.5) : _red.withValues(alpha: 0.5))
                      : accent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Gambar chord ',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                  Text(
                    _fmtChord(_chord!),
                    style: TextStyle(
                      color: _isReviewing ? (_isCorrect ? _green : _red) : accent,
                      fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.5,
                    ),
                  ),
                  if (!_isReviewing) ...[
                    const SizedBox(width: 10),
                    Text(_chordNotes(_chord!).join(' '),
                        style: TextStyle(color: accent.withValues(alpha: 0.45), fontSize: 11)),
                  ],
                  if (_isReviewing) ...[
                    const SizedBox(width: 10),
                    ScaleTransition(
                      scale: _resultAnim,
                      child: Icon(
                        _isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: _isCorrect ? _green : _red, size: 24,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

        const SizedBox(height: 8),

        // ── Fretboard area ───────────────────────────────────────────────
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: accent.withValues(alpha: 0.12)),
              ),
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: Column(children: [
                _buildMuteRow(accent),
                const SizedBox(height: 4),
                Expanded(child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: InteractiveFretboardWidget(
                      placedDots:   _dots,
                      mutedStrings: _muted,
                      onTap:        _onTap,
                      reviewMode:   _isReviewing,
                      reviewColors: revColors,
                      baseFret:     _baseFret,
                    )),
                    _buildFretNav(accent),
                  ],
                )),
                if (_isReviewing && !_isCorrect && _chord != null)
                  _buildRefPanel(accent),
              ]),
            ),
          ),
        )),

        const SizedBox(height: 10),

        // ── Tombol bawah ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Row(children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  onPressed: _isReviewing
                      ? null
                      : () => setState(() {
                            _dots  = [];
                            _muted = List.filled(6, false);
                          }),
                  icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white38),
                  label: const Text('Reset',
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isReviewing
                        ? (_isCorrect
                            ? Colors.white.withValues(alpha: 0.05)
                            : _red.withValues(alpha: 0.12))
                        : accent.withValues(alpha: 0.15),
                    foregroundColor: _isReviewing
                        ? (_isCorrect ? Colors.white38 : _red)
                        : accent,
                    side: BorderSide(
                      color: _isReviewing
                          ? (_isCorrect
                              ? Colors.white.withValues(alpha: 0.1)
                              : _red.withValues(alpha: 0.5))
                          : accent,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  // Saat review benar → disabled | Saat review salah → bisa tap skip
                  onPressed: _isReviewing
                      ? (_isCorrect ? null : _skipReview)
                      : _submit,
                  child: Text(
                    _isReviewing
                        ? (_isCorrect ? 'Menilai...' : 'Lanjut →')
                        : 'SELESAI',
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        letterSpacing: 2, fontSize: 14),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ])),
    );
  }

  // ── Widget helpers ────────────────────────────────────────────────────────

  Widget _diffBadge(Color accent) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Text(widget.level.difficulty,
            style: TextStyle(color: accent, fontSize: 11, fontWeight: FontWeight.bold)),
      );

  Widget _buildMuteRow(Color accent) {
    const labels = ['E', 'A', 'D', 'G', 'B', 'e'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(6, (i) {
          final m = _muted[i];
          return GestureDetector(
            onTap: () => _toggleMute(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36, height: 28,
              decoration: BoxDecoration(
                color: m ? _red.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: m ? _red.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Center(child: Text(m ? '✕' : labels[i],
                  style: TextStyle(
                      color: m ? _red : Colors.white38,
                      fontSize: 12, fontWeight: FontWeight.bold))),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFretNav(Color accent) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _navBtn(Icons.keyboard_arrow_up_rounded, _baseFret > 1, () => _shiftBase(-1), accent),
          const SizedBox(height: 4),
          Container(
            width: 32,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: _baseFret > 1 ? accent.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _baseFret > 1 ? accent.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text('F$_baseFret', textAlign: TextAlign.center,
                style: TextStyle(
                    color: _baseFret > 1 ? accent : Colors.white38,
                    fontSize: 9, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 4),
          _navBtn(Icons.keyboard_arrow_down_rounded, _baseFret < 17, () => _shiftBase(1), accent),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, bool enabled, VoidCallback onTap, Color accent) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: enabled ? accent.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? accent.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Icon(icon, color: enabled ? accent : Colors.white12, size: 18),
        ),
      );

  Widget _buildRefPanel(Color accent) {
    final chord = _chord!;
    final notes = _chordNotes(chord);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(4, 8, 4, 4),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            onTap: () => setState(() => _showAnswerPanel = !_showAnswerPanel),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                Icon(Icons.lightbulb_outline_rounded, color: _red, size: 14),
                const SizedBox(width: 8),
                Text('Nada: ${notes.join('  ')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11)),
                const Spacer(),
                Text(
                  _showAnswerPanel ? 'Sembunyikan contoh' : 'Lihat contoh posisi',
                  style: TextStyle(color: _red, fontSize: 11),
                ),
                Icon(
                  _showAnswerPanel ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  color: _red, size: 16,
                ),
              ]),
            ),
          ),
          if (_showAnswerPanel)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: SizedBox(
                height: 160,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: ChordFretboardWidget(
                    shape: chord.shapes.first,
                    chordName: _fmtChord(chord),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}