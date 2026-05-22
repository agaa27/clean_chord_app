import '../models/validation_result.dart';
import 'movable_shape.dart';
import 'note_extractor.dart';

class ChordValidator {
  static ValidationResult validate({
    required List<int> targetFrets,
    required List<int> userFrets,
  }) {
    final targetNotes =
        NoteExtractor.extract(targetFrets);

    final userNotes =
        NoteExtractor.extract(userFrets);

    final notesMatch =
        _listEquals(targetNotes, userNotes);

    final shapeMatch =
        MovableShape.matches(
      targetFrets,
      userFrets,
    );

    final exactMatch =
        _listEquals(targetFrets, userFrets);

    return ValidationResult(
      isValid: notesMatch || shapeMatch,
      notesMatch: notesMatch,
      shapeMatch: shapeMatch,
      exactMatch: exactMatch,
    );
  }

  static bool _listEquals(
    List<int> a,
    List<int> b,
  ) {
    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }
}