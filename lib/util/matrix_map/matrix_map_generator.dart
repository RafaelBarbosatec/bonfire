import 'package:bonfire/bonfire.dart';

export 'map_terrain.dart';
export 'terrain_builder.dart';

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

class ItemMatrixProperties {
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

  ItemMatrixProperties(
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

  bool get isCenterTile {
    return valueLeft == value &&
        valueRight == value &&
        valueTop == value &&
        valueBottom == value &&
        valueBottomLeft == value &&
        valueBottomRight == value &&
        valueTopLeft == value &&
        valueTopRight == value;
  }

  @override
  String toString() {
    return 'NoiseProperties{value: $value, valueTop: $valueTop, valueTopLeft: $valueTopLeft, valueTopRight: $valueTopRight, valueBottom: $valueBottom, valueBottomLeft: $valueBottomLeft, valueBottomRight: $valueBottomRight, valueLeft: $valueLeft, valueRight: $valueRight, position: $position}';
  }
}

typedef TileModelBuilder = TileModel Function(ItemMatrixProperties properties);

class MatrixMapGenerator {
  static MapWorld generate({
    required List<List<double>> matrix,
    required TileModelBuilder builder,
  }) {
    List<TileModel> tiles = [];

    final w = matrix.first.length;
    final h = matrix.length;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        tiles.add(
          builder(
            ItemMatrixProperties(
              matrix[y][x],
              Vector2(x.toDouble(), y.toDouble()),
              valueTop: _tryGetValue(() => matrix[y - 1][x]),
              valueBottom: _tryGetValue(() => matrix[y + 1][x]),
              valueLeft: _tryGetValue(() => matrix[y][x - 1]),
              valueRight: _tryGetValue(() => matrix[y][x + 1]),
              valueBottomLeft: _tryGetValue(() => matrix[y + 1][x - 1]),
              valueBottomRight: _tryGetValue(() => matrix[y + 1][x + 1]),
              valueTopLeft: _tryGetValue(() => matrix[y - 1][x - 1]),
              valueTopRight: _tryGetValue(() => matrix[y - 1][x + 1]),
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
