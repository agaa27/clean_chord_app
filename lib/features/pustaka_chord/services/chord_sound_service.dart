import 'package:audioplayers/audioplayers.dart';
import '../../../core/chord/utils/chord_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ChordSoundService — muter preview suara chord (assets/audio/chords/*.wav).
// 1 file per SHAPE/voicing, jadi geser posisi di Pustaka Chord bakal ganti
// bunyi sesuai bentuk fret yang lagi ditampilin.
//
// PENTING: pakai PlayerMode.mediaPlayer, BUKAN lowLatency. lowLatency di
// Android pakai backend SoundPool yang kadang nge-cache source lama dan gak
// reload pas dikasih AssetSource baru secara cepat/dinamis (gejalanya: suara
// gak ganti walau shape/chord udah beda) — makanya dulu kedengeran "sama
// aja" pas geser shape. mediaPlayer sedikit lebih lambat (~100-200ms) tapi
// selalu muter file yang benar-benar diminta.
//
// Source juga TIDAK di-preload di background — cuma di-set & diputar saat
// playChord() dipanggil eksplisit (dari tombol), biar gak ada kejadian
// suara nyala sendiri pas user cuma geser-geser posisi.
//
// CATATAN: sempet ditambahin _player.release() sebelum tiap play() sebagai
// "pengaman ekstra", tapi itu justru bikin delay & sesekali freeze (release()
// bongkar total resource native player, berat kalau dipanggil tiap tombol
// dipencet). Dicabut lagi — stop() + play() langsung udah cukup dan lebih
// ringan, PlayerMode.mediaPlayer sendirian udah cukup buat nyegah bug
// "suara gak ganti" dari sebelumnya.
// ─────────────────────────────────────────────────────────────────────────────
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
