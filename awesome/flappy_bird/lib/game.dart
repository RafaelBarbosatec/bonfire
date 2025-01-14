import 'package:bonfire/bonfire.dart';
import 'package:flappy_bird/components/bird.dart';
import 'package:flappy_bird/components/pipe/pipe_line_controller.dart';
import 'package:flappy_bird/components/scenario/background.dart';
import 'package:flappy_bird/components/scenario/base.dart';
import 'package:flappy_bird/widgets/score_widget.dart';
import 'package:flutter/material.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  late PipeLineController _pipeLineController;
  double speed = 80;
  static const maxHeight = 620.0;

  @override
  void initState() {
    _pipeLineController = PipeLineController(speed: speed);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaquery = MediaQuery.of(context);
    if (mediaquery.size.isEmpty) {
      return const SizedBox.shrink();
    }
    Vector2 sizeGame = Vector2(
      mediaquery.size.width,
      maxHeight,
    );
    return BonfireWidget(
      map: WorldMap.empty(size: sizeGame),
      player: Bird(
        position: (sizeGame / 2.1),
      ),
      playerControllers: [
        Keyboard(),
      ],
      background: ParallaxBackground(speed: speed),
      components: [
        _pipeLineController,
        ParallaxBaseBackground(speed: speed),
      ],
      globalForces: [
        AccelerationForce2D(
          id: 1,
          value: Vector2(0, 1000),
        ),
      ],
      cameraConfig: CameraConfig(
        initPosition: sizeGame / 2,
        startFollowPlayer: false,
        initialMapZoomFit: InitialMapZoomFitEnum.fitHeight,
      ),
      overlayBuilderMap: {
        ScoreWidget.name: (context, game) {
          return ScoreWidget(
            controller: _pipeLineController,
          );
        }
      },
      initialActiveOverlays: const [ScoreWidget.name],
    );
  }
}
