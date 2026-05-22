class FingerPosition {
  final int string;
  final int fret;
  final int finger;

  const FingerPosition({
    required this.string,
    required this.fret,
    this.finger = 0,
  });
}
