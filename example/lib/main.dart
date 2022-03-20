import 'package:bonfire/bonfire.dart';
import 'package:example/manual_map/game_manual_map.dart';
import 'package:example/shared/enemy/goblin_controller.dart';
import 'package:example/shared/npc/critter/critter_controller.dart';
import 'package:example/shared/interface/bar_life_controller.dart';
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Bonfire',
              style: TextStyle(fontSize: 30, color: Colors.white),
            ),
            SizedBox(
              height: 30,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text('Simple example'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SimpleExampleGame()),
                  );
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text('Manual Map'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameManualMap()),
                  );
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text('Tiled Map'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameTiledMap(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: Text('Top down game'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopDownGame(),
                    ),
                  );
                },
              ),
            ),
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
}
