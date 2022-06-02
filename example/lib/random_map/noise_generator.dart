import 'package:fast_noise/fast_noise.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 02/06/22
List<List<double>> generateNoise(Map<String, dynamic> data) {
  final original = noise2(
    data['w'],
    data['h'],
    seed: data['seed'],
    frequency: data['frequency'],
    noiseType: data['noiseType'],
    cellularDistanceFunction: data['cellularDistanceFunction'],
  );
  int width = original.first.length;
  int height = original.length;
  List<List<double>> newMatrix = List<List<double>>.generate(
      width, (_) => List<double>.generate(height, (_) => .0));
  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      double newValue = 0;
      if (original[x][y] > -0.35) {
        newValue = 0;
      }

      if (original[x][y] > -0.1) {
        newValue = 1;
      }

      if (original[x][y] > 0.1) {
        newValue = 2;
      }
      newMatrix[x][y] = newValue;
    }
  }
  return newMatrix;
}
