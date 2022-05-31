import 'package:bonfire/bonfire.dart';

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
/// on 30/05/22
///

class NoiseProperties {
  final double height;
  final Vector2 position;

  NoiseProperties(this.height, this.position);
}

typedef TileModelBuilder = TileModel Function(NoiseProperties properties);

class NoiseMapGenerator {
  static MapWorld generate({
    required List<List<double>> matrix,
    required TileModelBuilder builder,
  }) {
    List<TileModel> tiles = [];

    final w = matrix.first.length;
    final h = matrix.length;
    for (var x = 0; x < w; x++) {
      for (var y = 0; y < h; y++) {
        tiles.add(
          builder(
            NoiseProperties(
              matrix[x][y],
              Vector2(x.toDouble(), y.toDouble()),
            ),
          ),
        );
      }
    }
    return MapWorld(tiles);
  }
}
