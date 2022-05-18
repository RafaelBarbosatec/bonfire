import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';

enum ReceivesAttackFromEnum { ALL, ENEMY, PLAYER_AND_ALLY, NONE }
enum AttackFromEnum { ENEMY, PLAYER_OR_ALLY }

/// Mixin responsible for adding damage-taking behavior to the component.
mixin Attackable on GameComponent {
  /// Used to define which type of component can be damaged
  ReceivesAttackFromEnum receivesAttackFrom = ReceivesAttackFromEnum.ALL;

  /// Life of the Enemy.
  double _life = 100;

  /// Max life of the Enemy.
  double _maxLife = 100;
  double get maxLife => _maxLife;

  bool _isDead = false;

  double get life => _life;
  set life(double life) => _life = life;

  void initialLife(double life) {
    _life = life;
    _maxLife = life;
  }

  /// increase life
  void addLife(double life) {
    this.life += life;
    if (this.life > maxLife) {
      this.life = maxLife;
    }
  }

  /// reduce life
  void removeLife(double life) {
    if (this.life > 0) {
      this.life -= life;
    }
    if (this.life <= 0 && !_isDead) {
      die();
    }
  }

  /// This method is called to give damage a this component.
  /// Only receive damage if the method [checkCanReceiveDamage] return `true`.
  void receiveDamage(
    AttackFromEnum attacker,
    double damage,
    dynamic identify,
  ) {
    if (checkCanReceiveDamage(attacker, damage, identify)) {
      removeLife(damage);
    }
  }

  /// This method is used to check if this component can receive damage from any attacker.
  bool checkCanReceiveDamage(
    AttackFromEnum attacker,
    double damage,
    dynamic from,
  ) {
    switch (receivesAttackFrom) {
      case ReceivesAttackFromEnum.ALL:
        return true;
      case ReceivesAttackFromEnum.ENEMY:
        if (attacker == AttackFromEnum.ENEMY) {
          return true;
        }
        break;
      case ReceivesAttackFromEnum.PLAYER_AND_ALLY:
        if (attacker == AttackFromEnum.PLAYER_OR_ALLY) {
          return true;
        }
        break;
      case ReceivesAttackFromEnum.NONE:
        return false;
    }

    return false;
  }

  void die() {
    _isDead = true;
  }

  bool get isDead => _isDead;

  Rect rectAttackable() => rectConsideringCollision;
}
