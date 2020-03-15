import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/map/map_game.dart';
import 'package:bonfire/player/player.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/game_interface.dart';
import 'package:bonfire/util/joystick_controller.dart';
import 'package:flutter/material.dart';

class BonfireWidget extends StatefulWidget {
  final JoystickController joystick;
  final Player player;
  final GameInterface interface;
  final MapGame map;
  final List<Enemy> enemies;
  final List<GameDecoration> decorations;
  final Function(BuildContext context, RPGGame) listener;

  const BonfireWidget({
    Key key,
    @required this.joystick,
    @required this.player,
    @required this.map,
    this.interface,
    this.enemies,
    this.decorations,
    this.listener,
  }) : super(key: key);

  @override
  _BonfireWidgetState createState() => _BonfireWidgetState();
}

class _BonfireWidgetState extends State<BonfireWidget> {
  RPGGame _game;
  @override
  void initState() {
    _game = RPGGame(
      context: context,
      joystickController: widget.joystick,
      player: widget.player,
      interface: widget.interface,
      map: widget.map,
      decorations: widget.decorations,
      enemies: widget.enemies,
    )..addListener((game) {
        if (widget.listener != null) widget.listener(context, game);
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanStart: widget.joystick.onPanStart,
                  onPanUpdate: widget.joystick.onPanUpdate,
                  onPanEnd: widget.joystick.onPanEnd,
                  onTapDown: (d) {
                    widget.joystick.onTapDown(d);
                    _game.onTapDown(d);
                  },
                  onTapUp: (d) {
                    widget.joystick.onTapUp(d);
                    _game.onTapUp(d);
                  },
                  child: Container(),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) {
                    widget.joystick.onTapDownAction(d);
                    _game.onTapDown(d);
                  },
                  onTapUp: (d) {
                    widget.joystick.onTapUpAction(d);
                    _game.onTapUp(d);
                  },
                  onTapCancel: () {
                    widget.joystick.onTapCancelAction();
                  },
                  child: Container(),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
