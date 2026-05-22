import '../../../core/chord/engine/chord_validator.dart';
import '../../../core/chord/models/validation_result.dart';

class ChordGuessService {
  static ValidationResult validate({
    required List<int> target,
    required List<int> user,
  }) {
    return ChordValidator.validate(
      targetFrets: target,
      userFrets: user,
    );
  }
}