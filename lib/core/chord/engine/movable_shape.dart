import 'shape_normalizer.dart';

class MovableShape {
  static bool matches(
    List<int> a,
    List<int> b,
  ) {
    final na = ShapeNormalizer.normalize(a);
    final nb = ShapeNormalizer.normalize(b);

    if (na.length != nb.length) {
      return false;
    }

    for (int i = 0; i < na.length; i++) {
      if (na[i] != nb[i]) {
        return false;
      }
    }

    return true;
  }
}