import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class MapItem {
  final GameMap map;
  final Map<String, dynamic> properties;
  final Vector2 playerPosition;
  Key get key => UniqueKey();
  Object? arguments;

  MapItem({
    required this.map,
    required this.playerPosition,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};
}

class MapNavigatorController extends ChangeNotifier {
  final Map<String, MapItem> _maps;
  final String? _initialMap;
  late MapItem _currentMap;
  MapItem get current => _currentMap;

  MapNavigatorController({
    required Map<String, MapItem> maps,
    String? initialMap,
  })  : _maps = maps,
        _initialMap = initialMap {
    final map = _maps[_initialMap] ?? _maps.values.firstOrNull;
    if (map != null) {
      _currentMap = map;
    }
  }

  void toNamed(String name, {Object? arguments}) {
    final map = _maps[name];
    if (map != null) {
      _currentMap = map;
      _currentMap.arguments = arguments;
      notifyListeners();
    }
  }

  void toMap(MapItem map) {
    _currentMap = map;
    notifyListeners();
  }
}
