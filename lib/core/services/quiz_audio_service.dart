import 'package:audioplayers/audioplayers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// QuizAudioService — shared untuk kuis_chord & gambar_chord.
//
// Semua source di-set sekali saat init() → decoder tidak dibuat ulang tiap
// suara diputar. resume() jauh lebih ringan daripada play(AssetSource).
// ─────────────────────────────────────────────────────────────────────────────
class QuizAudioService {
  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer   = AudioPlayer();
  final AudioPlayer _winPlayer     = AudioPlayer();
  final AudioPlayer _failPlayer    = AudioPlayer();

  bool _initialized = false;
  bool _muted       = false;

  bool get isMuted => _muted;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _correctPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _wrongPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _winPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _failPlayer.setPlayerMode(PlayerMode.lowLatency);

      await _correctPlayer.setVolume(1.0);
      await _wrongPlayer.setVolume(1.0);
      await _winPlayer.setVolume(1.0);
      await _failPlayer.setVolume(1.0);

      await _correctPlayer.setReleaseMode(ReleaseMode.stop);
      await _wrongPlayer.setReleaseMode(ReleaseMode.stop);
      await _winPlayer.setReleaseMode(ReleaseMode.stop);
      await _failPlayer.setReleaseMode(ReleaseMode.stop);

      // setSource sekali → resume() berikutnya tidak buat MediaCodec baru
      await _correctPlayer.setSource(AssetSource('audio/quiz_correct.mp3'));
      await _wrongPlayer.setSource(AssetSource('audio/quiz_wrong.mp3'));
      await _winPlayer.setSource(AssetSource('audio/quiz_win.mp3'));
      await _failPlayer.setSource(AssetSource('audio/quiz_fail.mp3'));

      _initialized = true;
    } catch (_) {
      // Kalau file belum ada, game tetap jalan tanpa crash
    }
  }

  void toggleMute() => _muted = !_muted;
  void setMute(bool v) => _muted = v;

  Future<void> playCorrect() => _play(_correctPlayer);
  Future<void> playWrong()   => _play(_wrongPlayer);
  Future<void> playWin()     => _play(_winPlayer);
  Future<void> playFail()    => _play(_failPlayer);

  Future<void> _play(AudioPlayer p) async {
    if (_muted) return;
    try {
      await p.stop();
      await p.resume();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _correctPlayer.dispose();
    await _wrongPlayer.dispose();
    await _winPlayer.dispose();
    await _failPlayer.dispose();
    _initialized = false;
  }
}
