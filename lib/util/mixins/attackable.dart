import 'dart:ui';

import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/collision/object_collision.dart';

enum ReceivesAttackFromEnum { ALL, ENEMY, PLAYER }
enum AttackFromEnum { ENEMY, PLAYER }

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

  /// increase life in the player
  void addLife(double life) {
    this.life += life;
    if (this.life > maxLife) {
      this.life = maxLife;
    }
  }

  void receiveDamage(double damage, dynamic from) {
    if (life > 0) {
      life -= damage;
    }
    if (life <= 0) {
      die();
    }
  }

  void die() {
    _isDead = true;
  }

  bool get isDead => _isDead;

  Rect rectAttackable() => this.isObjectCollision()
      ? (this as ObjectCollision).rectCollision
      : toRect();

  bool receivesAttackFromPlayer() {
    return receivesAttackFrom == ReceivesAttackFromEnum.ALL ||
        receivesAttackFrom == ReceivesAttackFromEnum.PLAYER;
  }

  bool receivesAttackFromEnemy() {
    return receivesAttackFrom == ReceivesAttackFromEnum.ALL ||
        receivesAttackFrom == ReceivesAttackFromEnum.ENEMY;
  }
}
