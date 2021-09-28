import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

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
/// on 28/09/21
class FollowerWidget extends StatefulWidget {
  final GameComponent target;
  final Widget child;
  final Offset align;
  const FollowerWidget({
    Key? key,
    required this.target,
    required this.child,
    this.align = Offset.zero,
  }) : super(key: key);
  static OverlayEntry show(
    BuildContext context,
    GameComponent target,
    Widget child, {
    Offset align = Offset.zero,
  }) {
    final overlay = OverlayEntry(
      builder: (context) {
        return FollowerWidget(
          target: target,
          align: align,
          child: child,
        );
      },
    );

    Overlay.of(context)?.insert(overlay);

    return overlay;
  }

  @override
  _FollowerWidgetState createState() => _FollowerWidgetState();
}

class _FollowerWidgetState extends State<FollowerWidget> {
  Vector2 targetPosition = Vector2.zero();
  Offset? widgetPosition;
  double lastZoom = 0.0;
  Offset lastCameraPosition = Offset.zero;

  async.Timer? _timerUpdate;
  @override
  void initState() {
    Future.delayed(Duration.zero, _startFollow);
    super.initState();
  }

  @override
  void dispose() {
    _timerUpdate?.cancel();
    _timerUpdate = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widgetPosition != null) {
      return Positioned(
        top: widgetPosition!.dy + widget.align.dy,
        left: widgetPosition!.dx + widget.align.dx,
        child: widget.child,
      );
    }
    return SizedBox.shrink();
  }

  void _startFollow() {
    final camera = widget.target.gameRef.camera;
    _timerUpdate = async.Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (targetPosition != widget.target.vectorPosition ||
          camera.config.zoom != lastZoom ||
          camera.position != lastCameraPosition) {
        lastCameraPosition = camera.position;
        lastZoom = camera.config.zoom;
        targetPosition = widget.target.vectorPosition;
        if (mounted) {
          setState(() {
            widgetPosition = camera.worldPositionToScreen(
              targetPosition.toOffset(),
            );
          });
        }
      }
    });
  }
}
