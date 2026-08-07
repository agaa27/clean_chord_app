import 'package:audioplayers/audioplayers.dart';
import '../../../core/chord/utils/chord_utils.dart';

class ChordSoundService {
  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await _player.setPlayerMode(PlayerMode.mediaPlayer);
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(1.0);
      _initialized = true;
    } catch (_) {
      // kalau gagal init, tombol tetap ada tapi diem2 aja pas ditekan
    }
  }

  String _fileNameFor(String root, String type, int shapeIndex) =>
      '${chordSoundFileName(root, type)}_$shapeIndex';

  /// Mainin suara chord+shape yang lagi aktif. HANYA dipanggil dari
  /// interaksi eksplisit user (tombol), bukan dari perubahan state lain.
  /// Return true kalau berhasil mulai play, false kalau file gagal dimuat.
  Future<bool> playChord(String root, String type, int shapeIndex) async {
    if (!_initialized) await init();
    final fileName = _fileNameFor(root, type, shapeIndex);
    try {
      await _player.stop();
      await _player
          .release(); // pastiin source lama beneran dilepas, bukan cuma di-pause
      await _player.play(AssetSource('audio/chords/$fileName.wav'));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    _initialized = false;
  }
}
