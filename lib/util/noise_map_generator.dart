import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/map_world.dart';
import 'package:bonfire/map/tile/tile_model.dart';

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
    required List<List<double>> noiseMatrix,
    required TileModelBuilder builder,
  }) {
    List<TileModel> tiles = [];

    final w = noiseMatrix.length;
    final h = noiseMatrix.first.length;
    for (var x = 0; x < w; x++) {
      for (var y = 0; y < h; y++) {
        tiles.add(
          builder(
            NoiseProperties(
              noiseMatrix[x][y],
              Vector2(x.toDouble(), y.toDouble()),
            ),
          ),
        );
      }
    }
    return MapWorld(tiles);
  }
}
