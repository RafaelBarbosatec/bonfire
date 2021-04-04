class AssetToLoad<T> {
  Function(T? value)? callback;
  final Future<T>? future;

  AssetToLoad(this.future, this.callback);
  Future<void> load() async {
    if (future == null) {
      return Future.value();
    }
    callback?.call(await future);
  }
}

class AssetsLoader<T> {
  final List<AssetToLoad> _assets = [];

  void add(AssetToLoad asset) => _assets.add(asset);

  Future<void> load() async {
    await Future.forEach<AssetToLoad>(_assets, (element) => element.load());
    _assets.forEach((element) => element.callback = null);
    _assets.clear();
  }
}
