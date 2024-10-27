import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class MapItem {
  final String id;
  final GameMap map;
  final Map<String, dynamic> properties;

  MapItem({
    required this.id,
    required this.map,
    Map<String, dynamic>? properties,
  }) : properties = properties ?? {};
}

class MapNavigatorController extends ChangeNotifier {
  final Map<String, MapItemBuilder> _maps;
  final String? _initialMap;
  late MapItemBuilder _currentMap;
  Object? _arguments;
  MapItemBuilder get current => _currentMap;
  Object? get arguments => _arguments;

  MapNavigatorController({
    required Map<String, MapItemBuilder> maps,
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
      _arguments = arguments;
      notifyListeners();
    }
  }

  void toMap(MapItem map, {Object? arguments}) {
    _currentMap = (_, __) => map;
    _arguments = arguments;
    notifyListeners();
  }
}
