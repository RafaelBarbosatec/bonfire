import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/game_manual_map.dart';
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

  BonfireInjector().put((i) => KnightController());
  BonfireInjector().putFactory((i) => GoblinController());
  BonfireInjector().putFactory((i) => CritterController());
  BonfireInjector().put((i) => BarLifeController());

  runApp(
    MaterialApp(
      home: Menu(),
    ),
  );
}

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[900],
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Center(
              child: RichText(
                text: TextSpan(
                    text: 'Bonfire',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    children: [
                      TextSpan(
                        text: '  v2.5.0',
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      )
                    ]),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            _buildButton(context, 'Simple example', () {
              _navTo(context, SimpleExampleGame());
            }),
            SizedBox(
              height: 10,
            ),
            _buildButton(context, 'Manual Map', () {
              _navTo(context, GameManualMap());
            }),
            SizedBox(
              height: 10,
            ),
            _buildButton(context, 'Random Map', () {
              _navTo(
                context,
                RandomMapGame(
                  size: Vector2(200, 200),
                ),
              );
            }),
            SizedBox(
              height: 10,
            ),
            _buildButton(context, 'Tiled Map', () {
              _navTo(context, GameTiledMap());
            }),
            SizedBox(
              height: 10,
            ),
            _buildButton(context, 'Top down game', () {
              _navTo(context, TopDownGame());
            }),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
    return Center(
      child: SizedBox(
        width: 200,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: Text(label),
          onPressed: onTap,
        ),
      ),
    );
  }

  void _navTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }
}
