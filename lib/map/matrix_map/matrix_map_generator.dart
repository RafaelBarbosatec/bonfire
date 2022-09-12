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

/// Class useful to create radom map.
/// * [matrix], Matrix used to create the map.
/// * [build], Builder used to create the TileModel that represents each tile in the map.
/// * [axisInverted], used to invert axis of the matrix. Example: matrix[x,y] turn matrix[y,x]. It's useful to use an easier-to-see array in code.
class MatrixMapGenerator {
  static WorldMap generate({
    required List<List<double>> matrix,
    required TileModelBuilder builder,
    bool axisInverted = false,
  }) {
    List<TileModel> tiles = [];

    if (axisInverted) {
      tiles = _buildInverted(matrix, builder);
    } else {
      tiles = _buildNormal(matrix, builder);
    }

    return WorldMap(tiles);
  }

  static double? _tryGetValue(double Function() getValue) {
    try {
      return getValue();
    } catch (e) {
      return null;
    }
  }

  static List<TileModel> _buildNormal(
    List<List<double>> matrix,
    TileModelBuilder builder,
  ) {
    List<TileModel> tiles = [];
    final h = matrix.first.length;
    final w = matrix.length;
    for (var x = 0; x < w; x++) {
      for (var y = 0; y < h; y++) {
        tiles.add(
          builder(
            ItemMatrixProperties(
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
    return tiles;
  }

  static List<TileModel> _buildInverted(
    List<List<double>> matrix,
    TileModelBuilder builder,
  ) {
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
    return tiles;
  }
}
