abstract class TiledCacheProvider {
  Future<Map<String, dynamic>> get(String key);
  void put(String key, Map<String, dynamic> data);
  Future<bool> containsKey(String key);
}
