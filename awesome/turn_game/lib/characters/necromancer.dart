import 'package:bonfire/bonfire.dart';
import 'package:turn_game/main.dart';
import 'package:turn_game/spritesheet/spritesheet_builder.dart';
import 'package:turn_game/util/player_ally.dart';
import 'package:turn_game/util/player_enemy.dart';

class Necromancer extends PlayerEnemy {
  @override
  // ignore: overridden_fields
  Vector2 countTileRadiusAttack = Vector2.all(3);
  Necromancer({required super.position})
      : super(
          size: tileSize,
          animation: SpriteSheetBuilder.build(
            SpriteSheetBuilder.SPRITE_NECROMANCER,
          ),
        );

  @override
  void doAttackAlly(PlayerAlly ally) {
    int distance = center.distanceTo(ally.center).round();
    if (distance * 0.9 > tileSize.x) {
      simpleAttackRangeByAngle(
        animation: SpriteSheetBuilder.fireballRight,
        size: size,
        angle: BonfireUtil.angleBetweenPoints(center, ally.center),
        damage: 20,
        attackFrom: AttackOriginEnum.ENEMY,
        onDestroy: turnManager.doAction,
        marginFromOrigin: tileSize.x,
      );
    } else {
      ally.life.handleAttack(AttackOriginEnum.ENEMY, 25, 0);
      simpleAttackMeleeByAngle(
        animation: SpriteSheetBuilder.attackRight,
        size: size,
        angle: BonfireUtil.angleBetweenPoints(center, ally.center),
        damage: 0,
        attackFrom: AttackOriginEnum.ENEMY,
        withPush: false,
      );
      Future.delayed(const Duration(milliseconds: 300))
          .then((value) => turnManager.doAction());
    }
  }
}
