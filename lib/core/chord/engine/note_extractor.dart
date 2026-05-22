class NoteExtractor {
  static const tuning = [4, 9, 2, 7, 11, 4];

  static List<int> extract(
    List<int> frets,
  ) {
    final notes = <int>[];

    for (int i = 0; i < frets.length; i++) {
      final fret = frets[i];

      if (fret < 0) continue;

      final note = (tuning[i] + fret) % 12;

      notes.add(note);
    }

    notes.sort();

    return notes.toSet().toList();
  }
}