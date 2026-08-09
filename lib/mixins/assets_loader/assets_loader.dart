import 'package:bonfire/mixins/assets_loader/assets_loader_api.dart';
import 'package:flame/components.dart';

export 'assets_loader_api.dart';

/// Mixin used to load assets during the component [onLoad].
///
/// Access asset loading functionality through the [assetsLoader] API.
mixin WithAssetsLoader on Component {
  late final AssetsLoaderApi assetsLoader = AssetsLoaderApi();

  @override
  Future<void> onLoad() async {
    await assetsLoader.load();
    return super.onLoad();
  }
}
