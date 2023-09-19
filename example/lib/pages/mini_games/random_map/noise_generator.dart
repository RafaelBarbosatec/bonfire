import 'package:example/pages/mini_games/random_map/map_generator.dart';
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
  int width = original.length;
  int height = original.first.length;
  List<List<double>> newMatrix = List<List<double>>.generate(
    width,
    (_) => List<double>.generate(height, (_) => .0),
  );

  /// Normalizes the matrix creating 3 categories: Water,Earth and Grass
  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      double newValue = 0;
      if (original[x][y] > -0.35) {
        newValue = MapGenerator.tileWater;
      }

      if (original[x][y] > -0.1) {
        newValue = MapGenerator.tileSand;
      }

      if (original[x][y] > 0.1) {
        newValue = MapGenerator.tileGrass;
      }
      newMatrix[x][y] = newValue;
    }
  }
  return newMatrix;
}
