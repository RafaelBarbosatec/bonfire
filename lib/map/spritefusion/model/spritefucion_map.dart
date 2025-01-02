// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class SpritefusionMap {
  final double tileSize;
  final double mapWidth;
  final double mapHeight;
  final List<SpritefusionMapLayer> layers;
  String imgPath;

  SpritefusionMap({
    required this.tileSize,
    required this.mapWidth,
    required this.mapHeight,
    required this.layers,
    this.imgPath = '',
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tileSize': tileSize,
      'mapWidth': mapWidth,
      'mapHeight': mapHeight,
      'imgPath': imgPath,
      'layers': layers.map((x) => x.toMap()).toList(),
    };
  }

  factory SpritefusionMap.fromMap(Map<String, dynamic> map) {
    return SpritefusionMap(
      tileSize: double.parse(map['tileSize'].toString()),
      mapWidth: double.parse(map['mapWidth'].toString()),
      mapHeight: double.parse(map['mapHeight'].toString()),
      imgPath: map['imgPath']?.toString() ?? '',
      layers: List<SpritefusionMapLayer>.from(
        (map['layers'] as List).map<SpritefusionMapLayer>(
          (x) => SpritefusionMapLayer.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SpritefusionMap.fromJson(String source) => SpritefusionMap.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}

class SpritefusionMapLayer {
  final String name;
  final bool collider;
  final List<SpritefusionMapLayerTile> tiles;

  SpritefusionMapLayer({
    required this.name,
    required this.tiles,
    this.collider = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'collider': collider,
      'tiles': tiles.map((x) => x.toMap()).toList(),
    };
  }

  factory SpritefusionMapLayer.fromMap(Map<String, dynamic> map) {
    return SpritefusionMapLayer(
      name: map['name'] as String,
      collider: map['collider'] as bool? ?? false,
      tiles: List<SpritefusionMapLayerTile>.from(
        (map['tiles'] as List).map<SpritefusionMapLayerTile>(
          (x) => SpritefusionMapLayerTile.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SpritefusionMapLayer.fromJson(String source) =>
      SpritefusionMapLayer.fromMap(json.decode(source) as Map<String, dynamic>);
}

class SpritefusionMapLayerTile {
  final String id;
  final int x;
  final int y;

  SpritefusionMapLayerTile({
    required this.id,
    required this.x,
    required this.y,
  });

  int get idInt => int.parse(id);

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'x': x,
      'y': y,
    };
  }

  factory SpritefusionMapLayerTile.fromMap(Map<String, dynamic> map) {
    return SpritefusionMapLayerTile(
      id: map['id'] as String,
      x: int.parse(map['x'].toString()),
      y: int.parse(map['y'].toString()),
    );
  }

  String toJson() => json.encode(toMap());

  factory SpritefusionMapLayerTile.fromJson(String source) =>
      SpritefusionMapLayerTile.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
}
