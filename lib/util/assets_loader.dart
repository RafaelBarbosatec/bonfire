class AssetToLoad<T> {
  Function(T? value)? callback;
  final Future<T>? future;

  AssetToLoad(this.future, this.callback);
  Future<void> load() async {
    if (future == null) {
      return Future.value();
    }
    callback?.call(await future);
    callback = null;
  }
}

class AssetsLoader<T> {
  final List<AssetToLoad> _assets = [];

  void add(AssetToLoad asset) => _assets.add(asset);

  Future<void> load() async {
    for (final element in _assets) {
      await element.load();
    }
    _assets.clear();
  }
}
