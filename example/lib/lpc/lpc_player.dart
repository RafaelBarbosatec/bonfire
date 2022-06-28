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
  CustomStatus customStatus;
  LPCPlayer({
    required Vector2 position,
    required this.customStatus,
  }) : super(
          position: position,
          size: Vector2.all(48),
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

  @override
  Future onLoad() async {
    animation = await LPCSpriteSheetLoader.geSpriteSheet(status: customStatus);
    return super.onLoad();
  }
}
