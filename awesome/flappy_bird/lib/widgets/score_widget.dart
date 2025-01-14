import 'package:flappy_bird/components/pipe/pipe_line_controller.dart';
import 'package:flutter/material.dart';

class ScoreWidget extends StatelessWidget {
  static const name = 'score';
  final PipeLineController controller;
  const ScoreWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) {
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.topCenter,
              child: Text(
                controller.countPipesWin.toString(),
                style: const TextStyle(
                  fontSize: 45,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
