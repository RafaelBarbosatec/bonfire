import 'package:example/multi_scenario/maps/map_biome_1.dart';
import 'package:example/multi_scenario/maps/map_biome_2.dart';
import 'package:example/multi_scenario/player/sprite_sheet_hero.dart';
import 'package:example/multi_scenario/utils/enums/map_id_enum.dart';
import 'package:example/multi_scenario/utils/enums/show_in_enum.dart';
import 'package:flutter/material.dart';

// For sake of simplicity, we are using global variables here
// But avoid using global variables in your production code, this is not
// considered a good practice in most cases.
MapBiomeId currentMapBiomeId = MapBiomeId.none;
late Function(MapBiomeId) selectMap;

class MultiScenario extends StatefulWidget {
  const MultiScenario({Key? key}) : super(key: key);

  @override
  State<MultiScenario> createState() => _MultiScenarioState();

  static Future<void> prepare() => SpriteSheetHero.load();
}

class _MultiScenarioState extends State<MultiScenario> {
  @override
  void dispose() {
    currentMapBiomeId = MapBiomeId.none;
    super.dispose();
  }

  @override
  void initState() {
    selectMap = (MapBiomeId id) {
      setState(() {
        if (id == MapBiomeId.none) {
          currentMapBiomeId = MapBiomeId.biome1;
        } else {
          currentMapBiomeId = id;
        }
      });
    };
    super.initState();
  }

  Widget _renderWidget() {
    switch (currentMapBiomeId) {
      case MapBiomeId.biome1:
        return const MapBiome1(showInEnum: ShowInEnum.right);
      case MapBiomeId.biome2:
        return const MapBiome2(showInEnum: ShowInEnum.left);
      default:
        return const MapBiome1();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _renderWidget(),
    );
  }
}
