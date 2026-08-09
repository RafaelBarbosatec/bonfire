import 'dart:async';

import 'package:flame/components.dart';

/// Represents an asset that will be loaded and its callback called.
class AssetToLoad<T> {
  Function(T? value)? callback;
  final FutureOr<T>? future;

  AssetToLoad(this.future, this.callback);

  Future<void> load() async {
    if (future == null) {
      return Future.value();
    }
    callback?.call(await future);
    callback = null;
  }
}

/// Utility to load a list of assets and clear callbacks afterwards.
class AssetsLoader<T> {
  final List<AssetToLoad> _assets = [];

  void add(AssetToLoad asset) => _assets.add(asset);

  FutureOr<void> load() async {
    for (final element in _assets) {
      await element.load();
    }
    _assets.clear();
  }
}

/// API that handles loading assets during the component lifecycle.
///
/// The parent component must be a [Component].
class AssetsLoaderApi {
  final AssetsLoader _loader = AssetsLoader();
  bool _loaded = false;

  void add(AssetToLoad asset) {
    _loader.add(asset);
  }

  /// Loads all registered assets. Should be called during [onLoad].
  Future<void> load() async {
    if (_loaded) {
      return;
    }
    await _loader.load();
    _loaded = true;
  }
}
