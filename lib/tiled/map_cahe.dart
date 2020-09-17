import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiledjsonreader/map/tiled_map.dart';

class MapCache {
  SharedPreferences _preferences;

  Future saveMap(String key, TiledMap map) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    _preferences.setString(key, jsonEncode(map.toJson()));
  }

  Future<TiledMap> getMap(String key) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    final json = _preferences.getString(key);
    if (json?.isNotEmpty == true) {
      return TiledMap.fromJson(jsonDecode(json));
    } else {
      return null;
    }
  }

  Future saveBase64(String key, String base64) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    _preferences.setString(key, base64);
  }

  Future<String> getBase64(String key) async {
    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }
    return _preferences.getString(key);
  }
}
