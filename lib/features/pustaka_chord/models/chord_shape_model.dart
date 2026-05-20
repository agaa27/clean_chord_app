class ChordShapeModel {
  final List<int> frets;
  final List<int> fingers;
  final int baseFret;
  final int? barreFret;
  final int? barreStartString;
  final int? barreEndString;

  ChordShapeModel({
    required this.frets,
    required this.fingers,
    this.baseFret = 1,
    this.barreFret,
    this.barreStartString,
    this.barreEndString,
  });
}
