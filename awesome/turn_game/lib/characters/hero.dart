import 'package:bonfire/bonfire.dart';
import 'package:turn_game/main.dart';
import 'package:turn_game/spritesheet/spritesheet_builder.dart';
import 'package:turn_game/util/player_ally.dart';
import 'package:turn_game/util/player_enemy.dart';

class PHero extends PlayerAlly {
  @override
  // ignore: overridden_fields
  Vector2 countTileRadiusAttack = Vector2.all(3);
  PHero({required super.position})
      : super(
          size: tileSize,
          animation: SpriteSheetBuilder.build(
            SpriteSheetBuilder.SPRITE_HERO,
          ),
        );

  @override
  void doAttackEnemy(PlayerEnemy enemy) {
    int distance = center.distanceTo(enemy.center).round();
    if (distance * 0.9 > tileSize.x) {
      simpleAttackRangeByAngle(
        animation: SpriteSheetBuilder.fireballRight,
        size: size,
        angle: BonfireUtil.angleBetweenPoints(center, enemy.center),
        damage: 20,
        attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
        onDestroy: turnManager.doAction,
        marginFromOrigin: tileSize.x,
      );
    } else {
      enemy.life.handleAttack(AttackOriginEnum.PLAYER_OR_ALLY, 25, 0);
      simpleAttackMeleeByAngle(
        animation: SpriteSheetBuilder.attackRight,
        size: size,
        angle: BonfireUtil.angleBetweenPoints(center, enemy.center),
        damage: 0,
        attackFrom: AttackOriginEnum.PLAYER_OR_ALLY,
        withPush: false,
      );
      Future.delayed(const Duration(milliseconds: 300))
          .then((value) => turnManager.doAction());
    }
  }
}
