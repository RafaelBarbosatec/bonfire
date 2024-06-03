import 'package:bonfire/bonfire.dart';
import 'package:example/pages/mini_games/lpc/lpc_sprite_sheet_loader.dart';
import 'package:example/pages/mini_games/lpc/widgets/dialog_custom_character.dart';

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
class LPCPlayer extends SimplePlayer with BlockMovementCollision {
  static String customWidgetKey = 'dialogCharacter';
  CustomStatus customStatus;
  LPCPlayer({
    required Vector2 position,
    required this.customStatus,
  }) : super(
          position: position,
          size: Vector2.all(48),
        );

  void showEditCharacter() {
    if (FollowerWidget.isVisible(customWidgetKey)) {
      FollowerWidget.remove(customWidgetKey);
    } else {
      FollowerWidget.show(
        identify: customWidgetKey,
        context: context,
        target: this,
        offset: Offset(size.x * 1.8, -100),
        child: DialogCustomCharacter(
          customStatus: customStatus,
          simpleAnimationChanged: (newAnimation, status) {
            customStatus = status;
            replaceAnimation(newAnimation);
          },
        ),
      );
    }
  }

  @override
  Future onLoad() async {
    add(
      RectangleHitbox(
        size: size / 3,
        position: Vector2(size.x / 3, size.y / 1.6),
      ),
    );
    animation = await LPCSpriteSheetLoader.geSpriteSheet(status: customStatus);
    return super.onLoad();
  }
}
