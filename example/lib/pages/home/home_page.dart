import 'package:bonfire/bonfire.dart';
import 'package:example/pages/collision/collision_page.dart';
import 'package:example/pages/enemy/enemy_page.dart';
import 'package:example/pages/forces/forces_page.dart';
import 'package:example/pages/home/widgets/drawer/home_drawer.dart';
import 'package:example/pages/home/widgets/home_content.dart';
import 'package:example/pages/input/drag/drag_gesture_page.dart';
import 'package:example/pages/input/keyboard/keyboard_page.dart';
import 'package:example/pages/input/mouse/mouse_input_page.dart';
import 'package:example/pages/input/move_camera_mouse/move_camera_page.dart';
import 'package:example/pages/input/tap/tap_gesture_page.dart';
import 'package:example/pages/lighting/lighting_page.dart';
import 'package:example/pages/map/spritefusion/spritefusion_page.dart';
import 'package:example/pages/map/terrain_builder/terrain_builder_page.dart';
import 'package:example/pages/map/tiled/tiled_network_page.dart';
import 'package:example/pages/map/tiled/tiled_page.dart';
import 'package:example/pages/mini_games/manual_map/game_manual_map.dart';
import 'package:example/pages/mini_games/multi_scenario/multi_scenario_game.dart';
import 'package:example/pages/mini_games/platform/platform_game.dart';
import 'package:example/pages/mini_games/random_map/random_map_game.dart';
import 'package:example/pages/mini_games/simple_example/simple_example_game.dart';
import 'package:example/pages/mini_games/tiled_map/game_tiled_map.dart';
import 'package:example/pages/mini_games/top_down_game/top_down_game.dart';
import 'package:example/pages/parallax/bonfire/bonfire_parallax_page.dart';
import 'package:example/pages/parallax/flame/parallax_page.dart';
import 'package:example/pages/path_finding/path_finding_page.dart';
import 'package:example/pages/performance/performance_game.dart';
import 'package:example/pages/player/platform/platform_player_page.dart';
import 'package:example/pages/player/rotation/rotation_player_page.dart';
import 'package:example/pages/player/simple/simple_player_page.dart';
import 'package:example/pages/shader/shader_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../player_controllers/player_controllers_page.dart';

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
                    shape: WidgetStatePropertyAll(
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
            name: 'Using Tiled',
            builder: (_) => const TiledPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/map/tiled',
          ),
          ItemDrawer(
            name: 'Using Tiled url',
            builder: (_) => const TiledNetworkPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/map/tiled',
          ),
          ItemDrawer(
            name: 'Using Spritefusion',
            builder: (_) => const SpritefusionPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/map/spritefusion',
          ),
          ItemDrawer(
            name: 'Using matrix',
            builder: (_) => const TerrainBuilderPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/map/terrain_builder',
          ),
        ],
      ),
      SectionDrawer(
        name: 'Input',
        itens: [
          ItemDrawer(
            name: 'TapGesture',
            builder: (_) => const TapGesturePage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/input/tap',
          ),
          ItemDrawer(
            name: 'DragGesture',
            builder: (_) => const DragGesturePage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/input/drag',
          ),
          ItemDrawer(
            name: 'MoveCamera',
            builder: (_) => const MoveCameraPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/input/move_camera_mouse',
          ),
          ItemDrawer(
            name: 'Mouse',
            builder: (_) => const MouseInputPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/input/mouse',
          ),
          ItemDrawer(
            name: 'Keyboard',
            builder: (_) => const KeyboardPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/input/keyboard',
          ),
          ItemDrawer(
            name: 'PlayerControllers',
            builder: (_) => const PlayerControllersPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/player_controllers',
          ),
        ],
      ),
      SectionDrawer(
        name: 'Player',
        itens: [
          ItemDrawer(
            name: 'SimplePlayer',
            builder: (_) => const SimplePlayerPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/player/simple',
          ),
          ItemDrawer(
            name: 'RotationPlayer',
            builder: (_) => const RotationPlayerPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/player/rotation',
          ),
          ItemDrawer(
            name: 'PlatformPlayer',
            builder: (_) => const PlatformPlayerPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/player/platform',
          )
        ],
      ),
      SectionDrawer(
        itens: [
          ItemDrawer(
            name: 'Enemy',
            builder: (_) => const EnemyPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/enemy',
          ),
        ],
      ),
      SectionDrawer(
        itens: [
          ItemDrawer(
            name: 'Forces',
            builder: (_) => const ForcesPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/forces',
          ),
        ],
      ),
      SectionDrawer(
        itens: [
          ItemDrawer(
            name: 'BlockMovementCollision',
            builder: (_) => const CollisionPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/forces',
          ),
        ],
      ),
      SectionDrawer(
        itens: [
          ItemDrawer(
            name: 'Lighting',
            builder: (_) => const LightingPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/lighting',
          ),
        ],
      ),
      SectionDrawer(
        itens: [
          ItemDrawer(
            name: 'PathFinding',
            builder: (_) => const PathFindingPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/path_finding',
          ),
        ],
      ),
      SectionDrawer(
        itens: [
          ItemDrawer(
            name: 'Shader',
            builder: (_) => const ShaderPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/shader',
          ),
        ],
      ),
      SectionDrawer(
        itens: [
          ItemDrawer(
            name: 'Performance',
            builder: (_) => const PerformanceGame(),
            codeUrl: '',
          ),
        ],
      ),
      SectionDrawer(
        name: 'Parallax',
        itens: [
          ItemDrawer(
            name: 'Parallax',
            builder: (_) => const ParallaxPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/parallax/flame',
          ),
          ItemDrawer(
            name: 'CameraParallax',
            builder: (_) => const BonfireParallaxPage(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/blob/develop/example/lib/pages/parallax/bonfire',
          ),
        ],
      ),
      SectionDrawer(
        name: 'Mini games',
        itens: [
          ItemDrawer(
            name: 'Map by Tiled',
            builder: (_) => const GameTiledMap(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/tree/develop/example/lib/pages/mini_games',
          ),
          ItemDrawer(
            name: 'Topdown game',
            builder: (_) => const TopDownGame(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/tree/develop/example/lib/pages/mini_games',
          ),
          ItemDrawer(
            name: 'Platform game',
            builder: (_) => const PlatformGame(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/tree/develop/example/lib/pages/mini_games',
          ),
          ItemDrawer(
            name: 'Multi scenario game',
            builder: (_) => const MultiScenario(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/tree/develop/example/lib/pages/mini_games',
          ),
          ItemDrawer(
            name: 'Random Map',
            builder: (_) => RandomMapGame(
              size: Vector2(100, 100),
            ),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/tree/develop/example/lib/pages/mini_games',
          ),
          ItemDrawer(
            name: 'Manual map game',
            builder: (_) => const GameManualMap(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/tree/develop/example/lib/pages/mini_games',
          ),
          ItemDrawer(
            name: 'Simple',
            builder: (_) => const SimpleExampleGame(),
            codeUrl:
                'https://github.com/RafaelBarbosatec/bonfire/tree/develop/example/lib/pages/mini_games',
          ),
        ],
      ),
    ];
  }

  _launch(String codeUrl) {
    launchUrl(Uri.parse(codeUrl));
  }
}
