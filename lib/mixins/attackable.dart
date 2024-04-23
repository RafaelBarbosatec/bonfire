import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

// ignore: constant_identifier_names
enum ReceivesAttackFromEnum { ALL, ENEMY, PLAYER_AND_ALLY, NONE }

// ignore: constant_identifier_names
enum AttackOriginEnum { ENEMY, PLAYER_OR_ALLY, WORLD }

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
    double newLife = _life + life;

    if (newLife > maxLife) {
      newLife = maxLife;
    }
    onRestoreLife(newLife - _life);
    _life = newLife;

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
    double newLife = _life - life;
    if (newLife < 0) {
      newLife = 0;
    }
    onRemoveLife(_life - newLife);
    _life = newLife;

    _verifyLimitsLife();
  }

  void onRemoveLife(double life) {}
  void onRestoreLife(double life) {}

  void _verifyLimitsLife() {
    if (_life > 0 && isDead) {
      onRevive();
    } else if (_life == 0 && !_isDead) {
      onDie();
    }
  }

  /// This method is called to give damage a this component.
  /// Only receive damage if the method [checkCanReceiveDamage] return `true`.
  void receiveDamage(
    AttackOriginEnum attacker,
    double damage,
    dynamic identify,
  ) {
    if (checkCanReceiveDamage(attacker)) {
      removeLife(damage);
    }
  }

  /// This method is used to check if this component can receive damage from any attacker.
  bool checkCanReceiveDamage(AttackOriginEnum attacker) {
    switch (receivesAttackFrom) {
      case ReceivesAttackFromEnum.ALL:
        return true;
      case ReceivesAttackFromEnum.ENEMY:
        if (attacker == AttackOriginEnum.ENEMY ||
            attacker == AttackOriginEnum.WORLD) {
          return true;
        }
        break;
      case ReceivesAttackFromEnum.PLAYER_AND_ALLY:
        if (attacker == AttackOriginEnum.PLAYER_OR_ALLY ||
            attacker == AttackOriginEnum.WORLD) {
          return true;
        }
        break;
      case ReceivesAttackFromEnum.NONE:
        return false;
    }

    return false;
  }

  void onDie() {
    _isDead = true;
  }

  void onRevive() {
    _isDead = false;
  }

  bool get isDead => _isDead;

  Rect rectAttackable() => rectCollision;
}
