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
class LPCPlayer extends SimplePlayer with ObjectCollision {
  static String customWidgetKey = 'dialogCharacter';
  CustomStatus customStatus;
  LPCPlayer({
    required Vector2 position,
    required this.customStatus,
  }) : super(
          position: position,
          size: Vector2.all(48),
        ) {
    setupCollision(
      CollisionConfig(
        collisions: [
          CollisionArea.rectangle(
            size: size / 3,
            align: Vector2(size.x / 3, size.y / 1.6),
          )
        ],
      ),
    );
  }

  void showEditCharacter() {
    if (FollowerWidget.isVisible(customWidgetKey)) {
      FollowerWidget.remove(customWidgetKey);
    } else {
      FollowerWidget.show(
        identify: customWidgetKey,
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
