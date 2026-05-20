import 'package:audioplayers/audioplayers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuizAudioService — satu instance, dipakai selama halaman game aktif.
//
// Asset path convention (letakkan di pubspec.yaml → flutter → assets):
//   assets/audio/quiz_correct.mp3   — jawaban benar (ting! positif)
//   assets/audio/quiz_wrong.mp3     — jawaban salah (buzz negatif)
//   assets/audio/quiz_win.mp3       — level berhasil diselesaikan (fanfare)
//   assets/audio/quiz_fail.mp3      — waktu habis / gagal (sad tone)
//
// Cara pemakaian:
//   final _audio = QuizAudioService();
//   await _audio.init();           // panggil di initState
//   _audio.playCorrect();
//   _audio.playWrong();
//   _audio.playWin();
//   _audio.playFail();
//   await _audio.dispose();        // panggil di dispose
// ─────────────────────────────────────────────────────────────────────────────

class QuizAudioService {
  // Empat player terpisah agar suara tidak saling cancel.
  // Misalnya: suara "benar" dan "win" bisa overlap jika poin pas di target.
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer   = AudioPlayer();
  final AudioPlayer _winPlayer     = AudioPlayer();
  final AudioPlayer _failPlayer    = AudioPlayer();

  bool _initialized = false;
  bool _muted       = false;

  bool get isMuted => _muted;

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    if (_initialized) return;
    // Set release mode agar player tidak otomatis dispose setelah selesai play
    await _correctPlayer.setReleaseMode(ReleaseMode.stop);
    await _wrongPlayer.setReleaseMode(ReleaseMode.stop);
    await _winPlayer.setReleaseMode(ReleaseMode.stop);
    await _failPlayer.setReleaseMode(ReleaseMode.stop);

    // Pre-load semua asset ke buffer agar tidak ada delay saat play pertama kali
    await _correctPlayer.setSource(AssetSource('audio/quiz_correct.mp3'));
    await _wrongPlayer.setSource(AssetSource('audio/quiz_wrong.mp3'));
    await _winPlayer.setSource(AssetSource('audio/quiz_win.mp3'));
    await _failPlayer.setSource(AssetSource('audio/quiz_fail.mp3'));

    _initialized = true;
  }

  // ── Mute toggle ───────────────────────────────────────────────────────────
  void toggleMute() => _muted = !_muted;
  void setMute(bool value) => _muted = value;

  // ── Play helpers ──────────────────────────────────────────────────────────

  /// Jawaban benar — nada pendek positif (~0.4 detik)
  Future<void> playCorrect() => _play(_correctPlayer);

  /// Jawaban salah — buzz pendek negatif (~0.4 detik)
  Future<void> playWrong() => _play(_wrongPlayer);

  /// Level selesai / menang — fanfare singkat (~1.5–2 detik)
  Future<void> playWin() => _play(_winPlayer);

  /// Waktu habis / gagal — nada menurun (~1–1.5 detik)
  Future<void> playFail() => _play(_failPlayer);

  Future<void> _play(AudioPlayer player) async {
    if (_muted) return;
    try {
      // Stop dulu kalau masih berbunyi (supaya tidak overlap pada player yang sama)
      await player.stop();
      await player.resume();
    } catch (_) {
      // Ignore audio errors — jangan sampai crash game karena file audio
    }
  }

  // ── Dispose ───────────────────────────────────────────────────────────────
  Future<void> dispose() async {
    await _correctPlayer.dispose();
    await _wrongPlayer.dispose();
    await _winPlayer.dispose();
    await _failPlayer.dispose();
    _initialized = false;
  }
}
