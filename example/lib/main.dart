import 'dart:convert';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/player/spine_player.dart';
import 'package:bonfire/spine/skeleton_animation.dart';
import 'package:example/lpc/lpc_game.dart';
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
import 'package:flutter/services.dart';

import 'manual_map/dungeon_map.dart';
import 'tiled_map/game_tiled_map_spine.dart';

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
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Bonfire',
                  style: TextStyle(fontSize: 30, color: Colors.white),
                  children: [
                    TextSpan(
                      text: '  v2.10.1',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            SingleChildScrollView(
              child: Wrap(
                runSpacing: 20,
                spacing: 20,
                children: [
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
                        size: Vector2(150, 150),
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
                  _buildButton(context, 'Spine', () async{
                     bool loaded=await load();
                     if(!loaded){
                       return;
                     }
                     SpinePlayer player=SpinePlayer(position: Vector2.all(32)*8, size: Vector2.all(32)*3, skeleton: skeleton);
                    _navTo(context, GameTiledMapWithSpine(player: player,));
                  }),
                  SizedBox(
                    height: 10,
                  ),
                  _buildButton(context, 'Top down game', () {
                    _navTo(context, TopDownGame());
                  }),
                  if (!kIsWeb) ...[
                    SizedBox(
                      height: 10,
                    ),
                    _buildButton(context, 'Dynamic spriteSheet', () {
                      _navTo(context, LPCGame());
                    }),
                  ]
                ],
              ),
            )
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
        child: Text(label),
        onPressed: onTap,
      ),
    );
  }

  void _navTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
  static const String pathPrefix = 'assets/skeletons/';

  String name = 'spineboy';

  late Set<String> animations;
  late SkeletonAnimation skeleton;
  Future<bool> load() async {
    animations = await loadAnimations();
    skeleton = await loadSkeleton(); ///加载骨骼动画

    return true;
  }

  Future<Set<String>> loadAnimations() async {
    final String skeletonFile = '$name.json'; ///加载json
    final String s = await rootBundle.loadString('$pathPrefix$name/$skeletonFile'); ///加载和解析为json格式
    final Map<String, dynamic> data = json.decode(s);

    return ((data['animations'] ?? <String, dynamic>{}) as Map<String, dynamic>)
        .keys
        .toSet(); ///加载角色的所有动画，当前只有一个spine。
  }

  Future<SkeletonAnimation> loadSkeleton() async =>
      SkeletonAnimation.createWithFiles(name, pathBase: pathPrefix);  ///加载纹理
}
