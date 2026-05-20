import 'chord_shape_model.dart';

class ChordModel {
  final String root;
  final String type;
  final List<ChordShapeModel> shapes;

  ChordModel({required this.root, required this.type, required this.shapes});
}
