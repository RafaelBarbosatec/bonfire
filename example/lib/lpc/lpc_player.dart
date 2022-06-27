import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/lpc/lpc_sprite_sheet_loader.dart';
import 'package:example/lpc/widgets/dialog_custom_character.dart';

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
class LPCPlayer extends SimplePlayer {
  static String _dialogKey = 'dialogCharacter';
  CustomStatus customStatus = CustomStatus();
  LPCPlayer({
    required Vector2 position,
    required SimpleDirectionAnimation animation,
  }) : super(
          position: position,
          size: Vector2.all(48),
          animation: animation,
        );

  void showEditCharacter() {
    if (FollowerWidget.isVisible(_dialogKey)) {
      FollowerWidget.remove(_dialogKey);
    } else {
      FollowerWidget.show(
        identify: _dialogKey,
        context: context,
        target: this,
        align: Offset(size.x * 1.8, -100),
        child: DialogCustomCharacter(
          customStatus: customStatus,
          simpleAnimationChanged: (newAnimation, status) async {
            customStatus = status;
            replaceAnimation(newAnimation);
          },
        ),
      );
    }
  }
}
