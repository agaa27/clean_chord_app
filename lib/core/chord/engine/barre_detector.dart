import '../models/barre_info.dart';
import '../models/finger_position.dart';

class BarreDetector {
  static List<BarreInfo> detect(List<FingerPosition> positions) {
    final result = <BarreInfo>[];

    for (int finger = 1; finger <= 4; finger++) {
      final group = positions.where((e) => e.finger == finger).toList();
      if (group.length < 2) continue;

      final fret = group.first.fret;
      final sameFret = group.every((e) => e.fret == fret);
      if (!sameFret) continue;

      final strings = group.map((e) => e.string).toList()..sort();

      bool contiguous = true;
      for (int i = 1; i < strings.length; i++) {
        if (strings[i] != strings[i - 1] + 1) {
          contiguous = false;
          break;
        }
      }
      if (!contiguous) continue;

      result.add(BarreInfo(
        finger: finger,
        fret: fret,
        startString: strings.first,
        endString: strings.last,
      ));
    }

    return result;
  }
}
