import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/lpc/lpc_player.dart';
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
/// on 27/06/22
class ButtonInterface extends StatelessWidget {
  static String name = 'button';
  final BonfireGame game;

  static ButtonInterface builder(BuildContext context, BonfireGame game) {
    return ButtonInterface(
      game: game,
    );
  }

  const ButtonInterface({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          child: const Text('Edit Character'),
          onPressed: () {
            if (game.player != null) {
              (game.player as LPCPlayer).showEditCharacter();
            }
          },
        ),
      ),
    );
  }
}
