import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/extensions/extensions.dart';

// ignore: constant_identifier_names
enum ReceivesAttackFromEnum { ALL, ENEMY, PLAYER_AND_ALLY, NONE }

// ignore: constant_identifier_names
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

  void initialLife(double life) {
    _life = life;
    _maxLife = life;
  }

  /// increase life
  void addLife(double life) {
    _life += life;
    _verifyLimitsLife();
  }

  void updateLife(double life, {bool verifyDieOrRevive = true}) {
    _life = life;
    if (verifyDieOrRevive) {
      _verifyLimitsLife();
    }
  }

  /// reduce life
  void removeLife(double life) {
    if (_life > 0) {
      _life -= life;
    }
    if (_life <= 0 && !_isDead) {
      die();
    }
  }

  void _verifyLimitsLife() {
    if (_life > maxLife) {
      _life = maxLife;
    }
    if (_life > 0 && isDead) {
      revive();
    } else if (_life <= 0 && !_isDead) {
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

  void revive() {
    _isDead = false;
  }

  bool get isDead => _isDead;

  Rect rectAttackable() => rectConsideringCollision;
}
