import 'package:bonfire/bonfire.dart';
import 'package:example/lpc/lpc_game.dart';
import 'package:example/manual_map/game_manual_map.dart';
import 'package:example/multi_scenario/multi_scenario.dart';
import 'package:example/random_map/random_map_game.dart';
import 'package:example/shared/enemy/goblin_controller.dart';
import 'package:example/shared/interface/bar_life_controller.dart';
import 'package:example/shared/npc/critter/critter_controller.dart';
import 'package:example/shared/player/knight_controller.dart';
import 'package:example/simple_example/simple_example_game.dart';
import 'package:example/tiled_map/game_tiled_map.dart';
import 'package:example/top_down_game/top_down_game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }

  BonfireInjector().putFactory((i) => KnightController());
  BonfireInjector().putFactory((i) => GoblinController());
  BonfireInjector().putFactory((i) => CritterController());
  BonfireInjector().put((i) => BarLifeController());

  runApp(
    const MaterialApp(
      home: Menu(),
    ),
  );
}

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[900],
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: RichText(
                text: const TextSpan(
                  text: 'Bonfire',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                  children: [
                    TextSpan(
                      text: '  v2.11.5',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            SingleChildScrollView(
              child: Wrap(
                runSpacing: 20,
                spacing: 20,
                children: [
                  _buildButton(context, 'Simple example', () {
                    _navTo(context, const SimpleExampleGame());
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildButton(context, 'Manual Map', () {
                    _navTo(context, GameManualMap());
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildButton(context, 'Random Map', () {
                    _navTo(
                      context,
                      RandomMapGame(
                        size: Vector2(150, 150),
                      ),
                    );
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildButton(context, 'Tiled Map', () {
                    _navTo(context, const GameTiledMap());
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildButton(context, 'Top down game', () {
                    _navTo(context, const TopDownGame());
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  _buildButton(context, 'Multi Scenario', () {
                    MultiScenario.prepare().then((_) {
                      _navTo(context, const MultiScenario());
                    });
                  }),
                  if (!kIsWeb) ...[
                    const SizedBox(
                      height: 10,
                    ),
                    _buildButton(context, 'Dynamic spriteSheet', () {
                      _navTo(context, const LPCGame());
                    }),
                  ]
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const SizedBox(
        height: 40,
        child: Center(
          child: Text(
            'Keyboard: directional and Space Bar to attack',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onTap) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }

  void _navTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
