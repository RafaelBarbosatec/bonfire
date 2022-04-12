import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

import 'mini_map_canvas.dart';

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
/// on 12/04/22
class MiniMap extends StatefulWidget {
  final BonfireGame game;
  const MiniMap({Key? key, required this.game}) : super(key: key);

  @override
  State<MiniMap> createState() => _MiniMapState();
}

class _MiniMapState extends State<MiniMap> {
  Vector2 cameraPosition = Vector2.zero();
  Vector2 playerPosition = Vector2.zero();
  @override
  void initState() {
    _initInterval();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: CustomPaint(
              painter: MiniMapCanvas(
                widget.game.visibleComponents().toList()
                  ..addAll(widget.game.map.getRendered()),
                widget.game.camera,
                widget.game.size,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initInterval() {
    async.Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (widget.game.camera.position != cameraPosition) {
        cameraPosition = widget.game.camera.position.clone();
        setState(() {});
      }

      if (widget.game.player?.position != playerPosition) {
        playerPosition = widget.game.player?.position.clone() ?? Vector2.zero();
        setState(() {});
      }
    });
  }
}
