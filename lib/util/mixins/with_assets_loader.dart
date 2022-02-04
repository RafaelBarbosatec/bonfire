import 'package:bonfire/base/game_component.dart';

import '../assets_loader.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 04/02/22
mixin WithAssetsLoader on GameComponent {
  /// Used to load assets in [onLoad]
  AssetsLoader? loader = AssetsLoader();
  @override
  Future<void> onLoad() async {
    await loader?.load();
    loader = null;
    return super.onLoad();
  }
}
