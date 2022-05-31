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
  final double value;
  final double? valueTop;
  final double? valueTopLeft;
  final double? valueTopRight;
  final double? valueBottom;
  final double? valueBottomLeft;
  final double? valueBottomRight;
  final double? valueLeft;
  final double? valueRight;
  final Vector2 position;

  NoiseProperties(
    this.value,
    this.position, {
    this.valueTop,
    this.valueTopLeft,
    this.valueTopRight,
    this.valueBottom,
    this.valueBottomLeft,
    this.valueBottomRight,
    this.valueLeft,
    this.valueRight,
  });

  @override
  String toString() {
    return 'NoiseProperties{value: $value, valueTop: $valueTop, valueTopLeft: $valueTopLeft, valueTopRight: $valueTopRight, valueBottom: $valueBottom, valueBottomLeft: $valueBottomLeft, valueBottomRight: $valueBottomRight, valueLeft: $valueLeft, valueRight: $valueRight, position: $position}';
  }
}

typedef TileModelBuilder = TileModel Function(NoiseProperties properties);

class MatrixMapGenerator {
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
              valueTop: _tryGetValue(() => matrix[x][y - 1]),
              valueBottom: _tryGetValue(() => matrix[x][y + 1]),
              valueLeft: _tryGetValue(() => matrix[x - 1][y]),
              valueRight: _tryGetValue(() => matrix[x + 1][y]),
              valueBottomLeft: _tryGetValue(() => matrix[x - 1][y + 1]),
              valueBottomRight: _tryGetValue(() => matrix[x + 1][y + 1]),
              valueTopLeft: _tryGetValue(() => matrix[x - 1][y - 1]),
              valueTopRight: _tryGetValue(() => matrix[x + 1][y - 1]),
            ),
          ),
        );
      }
    }
    return MapWorld(tiles);
  }

  static double? _tryGetValue(double Function() getValue) {
    try {
      return getValue();
    } catch (e) {
      return null;
    }
  }
}
