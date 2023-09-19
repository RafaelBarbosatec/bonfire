import 'package:bonfire/bonfire.dart';
import 'package:example/pages/home/widgets/home_content.dart';
import 'package:example/pages/home/widgets/home_drawer.dart';
import 'package:example/pages/map/terrain_builder/terrain_builder_page.dart';
import 'package:example/pages/map/tiled/tiled_page.dart';
import 'package:example/pages/mini_games/manual_map/game_manual_map.dart';
import 'package:example/pages/mini_games/multi_scenario/multi_scenario.dart';
import 'package:example/pages/mini_games/platform/platform_game.dart';
import 'package:example/pages/mini_games/random_map/random_map_game.dart';
import 'package:example/pages/mini_games/tiled_map/game_tiled_map.dart';
import 'package:example/pages/mini_games/top_down_game/top_down_game.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget content = const HomeContent();
  ItemDrawer? itemSelected;
  late List<SectionDrawer> menu;

  @override
  void initState() {
    menu = _buildMenu();
    itemSelected = menu.first.itens.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: const Text('Bonfire examples'),
      ),
      drawer: HomeDrawer(
        itemSelected: itemSelected,
        itens: menu,
        onChange: _onChange,
      ),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: content,
          ),
          if (itemSelected?.codeUrl.isNotEmpty == true)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () => _launch(itemSelected!.codeUrl),
                  style: const ButtonStyle(
                    shape: MaterialStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Source code',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  void _onChange(ItemDrawer value) {
    setState(() {
      itemSelected = value;
      content = value.builder(context);
    });
  }

  List<SectionDrawer> _buildMenu() {
    return [
      SectionDrawer(
        itens: [
          ItemDrawer(name: 'Home', builder: (_) => const HomeContent()),
        ],
      ),
      SectionDrawer(
        name: 'Map',
        itens: [
          ItemDrawer(
            name: 'Using tiled',
            builder: (_) => const TiledPage(),
            codeUrl: 'https://www.google.com.br',
          ),
          ItemDrawer(
            name: 'Using matrix',
            builder: (_) => const TerrainBuilderPage(),
            codeUrl: 'https://www.google.com.br',
          ),
        ],
      ),
      SectionDrawer(
        name: 'Mini games',
        itens: [
          ItemDrawer(
            name: 'Map by Tiled',
            builder: (_) => const GameTiledMap(),
            codeUrl: 'https://www.google.com.br',
          ),
          ItemDrawer(
            name: 'Topdown game',
            builder: (_) => const TopDownGame(),
            codeUrl: 'https://www.google.com.br',
          ),
          ItemDrawer(
            name: 'Platform game',
            builder: (_) => const PlatformGame(),
            codeUrl: 'https://www.google.com.br',
          ),
          ItemDrawer(
            name: 'Multi scenario game',
            builder: (_) => const MultiScenario(),
            codeUrl: 'https://www.google.com.br',
          ),
          ItemDrawer(
            name: 'Random Map',
            builder: (_) => RandomMapGame(
              size: Vector2(100, 100),
            ),
            codeUrl: 'https://www.google.com.br',
          ),
          ItemDrawer(
            name: 'Manual map game',
            builder: (_) => const GameManualMap(),
            codeUrl: 'https://www.google.com.br',
          ),
        ],
      ),
    ];
  }

  _launch(String codeUrl) {}
}
