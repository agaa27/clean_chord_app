import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

// Import library chord asli project Anda
import '../../pustaka_chord/data/chord_library.dart';
import '../../pustaka_chord/models/chord_model.dart';

// Import element pendukung Gambar Chord
import '../models/gambar_chord_level_model.dart';
import '../../kuis_chord/services/quiz_audio_service.dart'; 
import '../../kuis_chord/widgets/kuis_progress_bar.dart'; 
import '../widgets/interactive_freatboard_input.dart'; // Mengambil FretPosition lokal dari sini

// Helper penamaan chord
String formatChordName(ChordModel c) {
  if (c.type == 'major') return c.root;
  if (c.type == 'minor') return '${c.root}m';
  return '${c.root}${c.type}';
}

class GambarChordGamePage extends StatefulWidget {
  final GambarChordLevel level;
  const GambarChordGamePage({super.key, required this.level});

  @override
  State<GambarChordGamePage> createState() => _GambarChordGamePageState();
}

class _GambarChordGamePageState extends State<GambarChordGamePage> {
  int _points = 0;
  late int _timeLeft;
  Timer? _timer;
  ChordModel? _currentChord;
  bool _isGameOver = false;
  bool _showIntro = true;
  bool _dialogShowing = false;
  final Random _random = Random();

  // Menyimpan input user
  List<FretPosition> _userInputPositions = [];
  bool? _isLastAnswerCorrect; 

  final QuizAudioService _audio = QuizAudioService();

  static const Color _bg = Color(0xFF070A0F);
  static const Color _cyan = Color(0xFF00E5FF);
  static const Color _purple = Color(0xFFBD00FF);
  static const Color _orange = Color(0xFFFFAA00);
  static const Color _correct = Color(0xFF00E676);
  static const Color _wrong = Color(0xFFFF4C4C);

  Color get _accentColor {
    switch (widget.level.difficulty) {
      case 'Pemula': return _cyan;
      case 'Menengah': return _purple;
      case 'Mahir': return _orange;
      default: return _cyan;
    }
  }

  @override
  void initState() {
    super.initState();
    _timeLeft = widget.level.timeLimitSeconds;
    _audio.init();
    _generateNewQuestion();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audio.dispose();
    super.dispose();
  }

  void _startGame() {
    setState(() => _showIntro = false);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        t.cancel();
        if (!_isGameOver) {
          setState(() => _isGameOver = true);
          _audio.playFail();
          _showEndDialog();
        }
      }
    });
  }

  void _generateNewQuestion() {
    final validChords = chordLibrary
        .where((c) => widget.level.chordNames.contains(formatChordName(c)))
        .toList();

    if (validChords.isEmpty) return;

    setState(() {
      ChordModel nextChord;
      do {
        nextChord = validChords[_random.nextInt(validChords.length)];
      } while (nextChord == _currentChord && validChords.length > 1);
      
      _currentChord = nextChord;
      _userInputPositions = []; 
      _isLastAnswerCorrect = null; 
    });
  }

  void _handleFretTap(FretPosition tappedPos) {
    if (_isGameOver || _isLastAnswerCorrect != null) return;

    HapticFeedback.selectionClick();

    setState(() {
      int existingIndex = _userInputPositions.indexWhere(
        (pos) => pos.string == tappedPos.string
      );

      if (existingIndex != -1) {
        if (_userInputPositions[existingIndex].fret == tappedPos.fret) {
          _userInputPositions.removeAt(existingIndex);
        } else {
          _userInputPositions[existingIndex] = tappedPos;
        }
      } else {
        _userInputPositions.add(tappedPos);
      }
    });
  }

  // ── FIX ERROR 1: LOGIKA PENCOCOKAN INTERAKTIF DENGAN REFLECTION DATA ──
  void _checkAnswer() {
    if (_isGameOver || _currentChord == null || _userInputPositions.isEmpty) return;

    bool isCorrect = true;

    try {
      // Mengambil shape pertama dari model chord asli
      final shape = _currentChord!.shapes.first;
      
      // Mengantisipasi perbedaan penamaan properti di library asli Anda (fretPositions / positions / notes)
      dynamic libraryPositions;
      try {
        libraryPositions = (shape as dynamic).fretPositions;
      } catch (_) {
        try {
          libraryPositions = (shape as dynamic).positions;
        } catch (_) {
          libraryPositions = (shape as dynamic).notes;
        }
      }

      if (libraryPositions is List) {
        // Cek kesamaan jumlah ketukan
        if (_userInputPositions.length != libraryPositions.length) {
          isCorrect = false;
        } else {
          // Bandingkan koordinat string dan fret secara manual
          for (var userPos in _userInputPositions) {
            bool found = libraryPositions.any((libPos) =>
                libPos.string == userPos.string && libPos.fret == userPos.fret);
            
            if (!found) {
              isCorrect = false;
              break;
            }
          }
        }
      } else {
        isCorrect = false;
      }
    } catch (_) {
      isCorrect = false; // Pengaman jika struktur data library gagal diakses
    }

    setState(() => _isLastAnswerCorrect = isCorrect);

    if (isCorrect) {
      _audio.playCorrect();
      HapticFeedback.lightImpact();
      setState(() => _points++);

      if (_points >= widget.level.targetPoints) {
        _timer?.cancel();
        Future.delayed(const Duration(milliseconds: 500), () => _audio.playWin());
        Future.delayed(const Duration(milliseconds: 800), () => _showWinDialog());
        return;
      }
    } else {
      _audio.playWrong();
      HapticFeedback.heavyImpact();
      if (_points > 0) setState(() => _points--);
    }

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && !_isGameOver) {
        _generateNewQuestion();
      }
    });
  }

  void _showWinDialog() {
    if (_dialogShowing) return;
    _dialogShowing = true;
    _showResultDialog(
      icon: '🎉', 
      title: 'Hebat!', 
      titleColor: _correct, 
      message: 'Level selesai!\nSkor: $_points/${widget.level.targetPoints}',
      buttonText: 'Selesai', 
      onBtnTap: () => Navigator.pop(context),
    );
  }

  void _showEndDialog() {
    if (_dialogShowing) return;
    _dialogShowing = true;
    _showResultDialog(
      icon: '⏱', 
      title: 'Waktu Habis!', 
      titleColor: _wrong,
      message: 'Skor kamu: $_points', 
      buttonText: 'Coba Lagi', 
      onBtnTap: () {
        Navigator.pop(context); 
        setState(() {
          _points = 0; 
          _timeLeft = widget.level.timeLimitSeconds;
          _isGameOver = false; 
          _dialogShowing = false;
        });
        _generateNewQuestion();
        _startTimer();
      },
    );
  }

  void _showResultDialog({
    required String icon, 
    required String title, 
    required Color titleColor, 
    required String message, 
    required String buttonText, 
    required VoidCallback onBtnTap,
  }) {
    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (ctx) => PopScope(
        canPop: false, 
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24), 
            decoration: BoxDecoration(
              color: const Color(0xFF0D1520), 
              borderRadius: BorderRadius.circular(24), 
              border: Border.all(color: titleColor.withAlpha(76)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text(icon, style: const TextStyle(fontSize: 40)), 
                const SizedBox(height: 10),
                Text(title, style: TextStyle(color: titleColor, fontSize: 20, fontWeight: FontWeight.bold)), 
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 14)), 
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, 
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: titleColor), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ), 
                    onPressed: onBtnTap, 
                    child: Text(buttonText, style: TextStyle(color: titleColor)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _bg,
    body: SafeArea(
      child: _showIntro ? _buildIntro() : _buildGame(),
    ),
  );

  Widget _buildIntro() {
    final accent = _accentColor;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16), 
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white54, size: 18), 
                onPressed: () => Navigator.pop(context),
              ),
              Text('Level ${widget.level.id}', style: const TextStyle(color: Colors.white70)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), 
                decoration: BoxDecoration(
                  color: accent.withAlpha(25), 
                  borderRadius: BorderRadius.circular(12), 
                  border: Border.all(color: accent.withAlpha(76)),
                ),
                child: Text(widget.level.difficulty, style: TextStyle(color: accent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(20), 
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1520), 
              borderRadius: BorderRadius.circular(24), 
              border: Border.all(color: accent.withAlpha(51)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, 
              children: [
                Icon(Icons.fingerprint_rounded, size: 60, color: accent),
                const SizedBox(height: 20),
                Text('MODE: GAMBAR CHORD', style: TextStyle(color: accent, letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(widget.level.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                
                // FIX ERROR 2 & 3: Menggunakan kontras manual sebagai ganti Colors.black24 & withOpacity
                Container(
                  padding: const EdgeInsets.all(16), 
                  decoration: BoxDecoration(
                    color: const Color(0x3D000000), 
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start, 
                    children: [
                      Text('Cara Bermain:', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('1. Perhatikan nama chord yang muncul.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      Text('2. Tekan fretboard untuk menaruh titik not.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                      Text('3. Tekan "PERIKSA" untuk submit.', style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
                
                const Spacer(),
                Text('Target: ${widget.level.targetPoints} poin / ${widget.level.timeLimitSeconds}s', style: const TextStyle(color: Colors.white38)),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity, 
                  height: 50, 
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent, 
                      foregroundColor: Colors.black, 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: _startGame,
                    child: const Text('MENGERTI & MULAI', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGame() {
    final accent = _accentColor;
    
    Color fretboardBorderColor = Colors.white12;
    if (_isLastAnswerCorrect == true) fretboardBorderColor = _correct;
    if (_isLastAnswerCorrect == false) fretboardBorderColor = _wrong;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0), 
          child: Row(
            children: [
              Expanded(child: KuisProgressBar(currentPoints: _points, targetPoints: widget.level.targetPoints, accentColor: accent)),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), 
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13), 
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined, color: _timeLeft < 10 ? _wrong : Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text('${_timeLeft}s', style: TextStyle(color: _timeLeft < 10 ? _wrong : Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            color: accent.withAlpha(13), 
            borderRadius: BorderRadius.circular(15), 
            border: Border.all(color: accent.withAlpha(51)),
          ),
          child: Column(
            children: [
              const Text('GAMBARKAN CHORD:', style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 2)),
              const SizedBox(height: 2),
              Text(
                _currentChord != null ? formatChordName(_currentChord!) : '?',
                style: TextStyle(
                  color: accent, 
                  fontSize: 36, 
                  fontWeight: FontWeight.w900, 
                  shadows: [Shadow(color: accent, blurRadius: 10)],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: fretboardBorderColor, width: 2),
            ),
            child: InteractiveFretboardInput(
              userInput: _userInputPositions,
              onTap: _handleFretTap,
              accentColor: _isLastAnswerCorrect == false ? _wrong : accent, 
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton.outlined(
                onPressed: _isLastAnswerCorrect != null ? null : () => setState(() => _userInputPositions = []),
                icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white38),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white10)),
              ),
              const SizedBox(width: 15),
              
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isLastAnswerCorrect == null 
                          ? (_userInputPositions.isEmpty ? Colors.white10 : accent)
                          : (_isLastAnswerCorrect! ? _correct : _wrong),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: (_isLastAnswerCorrect != null || _userInputPositions.isEmpty) 
                        ? null 
                        : _checkAnswer,
                    icon: _buildSubmitIcon(),
                    label: Text(_buildSubmitLabel(), style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitIcon() {
    if (_isLastAnswerCorrect == null) return const Icon(Icons.check_circle_outline);
    if (_isLastAnswerCorrect!) return const Icon(Icons.check_circle, color: Colors.black);
    return const Icon(Icons.cancel, color: Colors.black);
  }

  String _buildSubmitLabel() {
    if (_isLastAnswerCorrect == null) return 'PERIKSA';
    if (_isLastAnswerCorrect!) return 'BENAR!';
    return 'SALAH!';
  }
}