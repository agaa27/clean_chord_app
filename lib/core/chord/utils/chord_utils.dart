// chord_utils.dart — helper penamaan chord, dipakai bareng2 di pustaka_chord,
// kuis_chord, gambar_chord, dan tebak_suara_chord biar konsisten.

/// Label tampilan chord, mis. ('C','major') -> 'C', ('C','minor') -> 'Cm',
/// ('C','7') -> 'C7'. Mirror persis logic yang sudah ada di kuis_chord &
/// pustaka_chord supaya semua fitur konsisten.
String chordDisplayName(String root, String type) {
  switch (type) {
    case 'major':
      return root;
    case 'minor':
      return '${root}m';
    default:
      return '$root$type';
  }
}

/// Nama file asset audio yang aman (tanpa '#', karena '#' rawan bikin
/// masalah resolusi path asset). C# -> Cs, F# -> Fs, dst.
/// Contoh: ('C#','minor') -> 'Csm', ('A','7') -> 'A7'.
String chordSoundFileName(String root, String type) {
  final safeRoot = root.replaceAll('#', 's');
  return chordDisplayName(safeRoot, type);
}
