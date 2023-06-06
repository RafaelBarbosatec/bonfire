import 'package:bonfire/bonfire.dart';
import 'package:example/main.dart';
import 'package:example/platform/fox_player.dart';
import 'package:example/platform/gem_decoration.dart';
import 'package:example/platform/platform_game.dart';
import 'package:flutter/material.dart';

class PlatformGameController extends GameComponent {
  bool showGameOver = false;
  bool showWin = false;
  @override
  void update(double dt) {
    if (checkInterval('check win', 500, dt)) {
      _checkWin();
      _checkGameOver();
    }
    super.update(dt);
  }

  void _checkWin() {
    var containGem = gameRef.componentsByType<GemDecoration>().isNotEmpty;
    if (!containGem && !showWin) {
      showWin = true;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Congratulation'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _checkGameOver() {
    if (gameRef.componentsByType<FoxPlayer>().isEmpty && !showGameOver) {
      showGameOver = true;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Game Over'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Menu(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlatformGame(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text('TRY AGAIN'),
              ),
            ],
          );
        },
      );
    }
  }
}
