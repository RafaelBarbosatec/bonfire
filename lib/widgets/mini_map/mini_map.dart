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

typedef MiniMapCustomRender = void Function(
    Canvas canvas, GameComponent component);

class MiniMap extends StatefulWidget {
  static MiniMapCustomRender tilesRenderDefault = (canvas, component) {
    if (component is ObjectCollision) {
      component.renderCollision(canvas, Colors.black);
    }
  };

  static MiniMapCustomRender componentsRenderDefault = (canvas, component) {
    if (component is ObjectCollision) {
      if (component is GameDecoration) {
        component.renderCollision(canvas, Colors.black);
      }
      if (component is Player) {
        component.renderCollision(canvas, Colors.cyan);
      } else if (component is Ally) {
        component.renderCollision(canvas, Colors.yellow);
      } else if (component is Enemy) {
        component.renderCollision(canvas, Colors.red);
      } else if (component is Npc) {
        component.renderCollision(canvas, Colors.green);
      }
    }
  };

  final BonfireGame game;
  final MiniMapCustomRender? tileRender;
  final MiniMapCustomRender? componentsRender;
  final Vector2 size;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final BoxBorder? border;
  MiniMap({
    Key? key,
    required this.game,
    this.tileRender,
    this.componentsRender,
    Vector2? size,
    this.margin,
    this.borderRadius,
    this.backgroundColor = Colors.grey,
    this.border,
  })  : this.size = size ?? Vector2(200, 200),
        super(key: key);

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
        padding: widget.margin ?? EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          child: Container(
            width: widget.size.x,
            height: widget.size.y,
            decoration: BoxDecoration(
              border: widget.border,
              color: widget.backgroundColor,
              borderRadius: widget.borderRadius,
            ),
            child: CustomPaint(
              painter: MiniMapCanvas(
                components: widget.game.visibleComponents().toList()
                  ..addAll(
                    widget.game.map.getRendered(),
                  ),
                cameraPosition: cameraPosition,
                gameSize: widget.game.size,
                componentsRender:
                    widget.componentsRender ?? MiniMap.componentsRenderDefault,
                tileRender: widget.tileRender ?? MiniMap.tilesRenderDefault,
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
