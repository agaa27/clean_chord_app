class ShapeNormalizer {
  static List<int> normalize(List<int> frets) {
    final positives = frets.where((f) => f > 0).toList();

    if (positives.isEmpty) {
      return frets;
    }

    final minFret = positives.reduce(
      (a, b) => a < b ? a : b,
    );

    return frets.map((f) {
      if (f <= 0) return f;
      return f - minFret;
    }).toList();
  }
}