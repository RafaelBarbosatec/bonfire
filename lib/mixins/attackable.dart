import 'dart:ui';

import 'package:bonfire/base/game_component.dart';

// ignore: constant_identifier_names
enum AcceptableAttackOriginEnum { ALL, ENEMY, PLAYER_AND_ALLY, NONE }

// ignore: constant_identifier_names
enum AttackOriginEnum { ENEMY, PLAYER_OR_ALLY, WORLD }

/// Mixin responsible for adding damage-taking behavior to the component.
mixin Attackable on GameComponent {
  /// Used to define which type of component can be damaged
  AcceptableAttackOriginEnum receivesAttackFrom =
      AcceptableAttackOriginEnum.ALL;

  /// Life of the Enemy.
  double _life = 100;

  /// Max life of the Enemy.
  double _maxLife = 100;
  double get maxLife => _maxLife;

  bool _isDead = false;

  double get life => _life;

  /// Set initial life
  void initialLife(double life) {
    _life = life;
    _maxLife = life;
  }

  /// Increase life
  void addLife(double life) {
    double newLife = _life + life;

    if (newLife > maxLife) {
      newLife = maxLife;
    }
    onRestoreLife(newLife - _life);
    _life = newLife;

    _verifyLimitsLife();
  }

  // Update life
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

  // Called when life is removed
  void onRemoveLife(double life) {}

  // Called when life is restored
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
  bool handleAttack(
    AttackOriginEnum attacker,
    double damage,
    dynamic identify,
  ) {
    final canReceive = checkCanReceiveDamage(attacker);
    if (canReceive) {
      onReceiveDamage(attacker, damage, identify);
    }
    return canReceive;
  }

  // Called when the component receives damage
  void onReceiveDamage(
    AttackOriginEnum attacker,
    double damage,
    dynamic identify,
  ) {
    removeLife(damage);
  }

  /// This method is used to check if this component can receive damage from any attacker.
  bool checkCanReceiveDamage(AttackOriginEnum attacker) {
    if (isDead || isRemoving) return false;
    switch (receivesAttackFrom) {
      case AcceptableAttackOriginEnum.ALL:
        return true;
      case AcceptableAttackOriginEnum.ENEMY:
        if (attacker == AttackOriginEnum.ENEMY ||
            attacker == AttackOriginEnum.WORLD) {
          return true;
        }
        break;
      case AcceptableAttackOriginEnum.PLAYER_AND_ALLY:
        if (attacker == AttackOriginEnum.PLAYER_OR_ALLY ||
            attacker == AttackOriginEnum.WORLD) {
          return true;
        }
        break;
      case AcceptableAttackOriginEnum.NONE:
        return false;
    }

    return false;
  }

  // Called when the component dies
  void onDie() {
    _isDead = true;
  }

  // Called when the component revives
  void onRevive() {
    _isDead = false;
  }

  bool get isDead => _isDead;

  // Get rect collision of the component used to receive damage
  Rect rectAttackable() => rectCollision;
}
