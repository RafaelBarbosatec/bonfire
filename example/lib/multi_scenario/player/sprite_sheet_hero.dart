import 'package:bonfire/bonfire.dart';
import 'package:example/multi_scenario/utils/constants/game_consts.dart';

class SpriteSheetHero {
  static Future<void> load() async {
    hero1 = await _create(MultiScenarioAssets.hero);
  }

  static Future<SpriteSheet> _create(String path) async {
    final image = await Flame.images.load(path);
    return SpriteSheet.fromColumnsAndRows(
      image: image,
      columns: 3,
      rows: 8,
    );
  }

  static late SpriteSheet hero1;
}
