import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/tile.dart';
import 'package:bonfire/tiled/tiled_world_data.dart';
import 'package:flame/sprite.dart';
import 'package:tiledjsonreader/map/layer/object_group.dart';
import 'package:tiledjsonreader/map/layer/tile_layer.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';
import 'package:tiledjsonreader/tile_set/tile_set.dart';
import 'package:tiledjsonreader/tiledjsonreader.dart';

typedef ObjectBuilder = GameComponent Function(double x, double y);

class TiledWorldMap {
  final String pathFile;
  final double forceTileSize;
  TiledJsonReader _reader;
  List<Tile> _tiles = List();
  List<Enemy> _enemies = List();
  List<GameDecoration> _decorations = List();
  String _basePath;
  String _basePathFlame = 'assets/images/';
  TiledMap _tiledMap;
  double _tileSize;
  double _tileSizeOrigin;
  Map<String, SpriteSheet> _spriteSheetsCache = Map();
  Map<String, Sprite> _spriteCache = Map();
  Map<String, ObjectBuilder> _objectsBuilder = Map();

  TiledWorldMap(this.pathFile, {this.forceTileSize}) {
    _basePath = pathFile.replaceAll(pathFile.split('/').last, '');
    _reader = TiledJsonReader(pathFile);
  }

  void registerObject(String name, ObjectBuilder builder) {
    _objectsBuilder[name] = builder;
  }

  Future<TiledWorldData> build() async {
    _tiledMap = await _reader.read();
    _tileSizeOrigin = _tiledMap.tileWidth.toDouble();
    _tileSize = forceTileSize ?? _tileSizeOrigin;
    _load(_tiledMap);
    return Future.value(TiledWorldData(
      map: MapWorld(_tiles),
      decorations: _decorations,
      enemies: _enemies,
    ));
  }

  void _load(TiledMap tiledMap) {
    tiledMap.layers.forEach((layer) {
      if (layer is TileLayer) {
        _addTileLayer(layer);
      }
      if (layer is ObjectGroup) {
        _addObjects(layer);
      }
    });
  }

  void _addTileLayer(TileLayer tileLayer) {
    int count = 0;
    tileLayer.data.forEach((tile) {
      if (tile != 0) {
        var data = getDataTile(tile);
        if (data != null) {
          _tiles.add(
            Tile.fromSprite(
              data.sprite,
              Position(
                _getX(count, tileLayer.width.toInt()),
                _getY(count, tileLayer.width.toInt()),
              ),
              collision: data.collision,
              size: _tileSize.toDouble(),
            ),
          );
        }
      }
      count++;
    });
  }

  double _getX(int index, int width) {
    return (index % width).toDouble();
  }

  double _getY(int index, int width) {
    return (index / width).floor().toDouble();
  }

  ItemTileSet getDataTile(int index) {
    TileSet tileSetContain;
    _tiledMap.tileSets.forEach((tileSet) {
      if (tileSet.tileSet != null && index <= tileSet.tileSet.tileCount) {
        tileSetContain = tileSet.tileSet;
      }
    });

    if (tileSetContain != null) {
      if (_spriteSheetsCache[tileSetContain.image] == null) {
        _spriteSheetsCache[tileSetContain.image] = SpriteSheet(
          imageName:
              '${_basePath.replaceAll(_basePathFlame, '')}${tileSetContain.image}',
          textureWidth: tileSetContain.tileWidth.toInt(),
          textureHeight: tileSetContain.tileHeight.toInt(),
          columns: tileSetContain.columns,
          rows: tileSetContain.tileCount ~/ tileSetContain.columns,
        );
      }

      final int widthCount =
          tileSetContain.imageWidth ~/ tileSetContain.tileWidth;

      int row = _getY(index - 1, widthCount).toInt();
      int column = _getX(index - 1, widthCount).toInt();

      Sprite sprite = _spriteCache['${tileSetContain.image}/$row/$column'];
      if (sprite == null) {
        sprite = _spriteCache['${tileSetContain.image}/$row/$column'] =
            _spriteSheetsCache[tileSetContain.image].getSprite(
          row,
          column,
        );
      }
      return ItemTileSet(
        sprite: sprite,
        collision: tileSetContain.tiles
            .where((element) => element.id == (index - 1))
            .isNotEmpty,
      );
    } else {
      return null;
    }
  }

  void _addObjects(ObjectGroup layer) {
    layer.objects.forEach((element) {
      double x = (element.x * _tileSize) / _tileSizeOrigin;
      double y = (element.y * _tileSize) / _tileSizeOrigin;
      var object = _objectsBuilder[element.name](x, y);

      if (object is Enemy) _enemies.add(object);
      if (object is GameDecoration) _decorations.add(object);
    });
  }
}

class ItemTileSet {
  final Sprite sprite;
  final bool collision;

  ItemTileSet({this.sprite, this.collision = false});
}
