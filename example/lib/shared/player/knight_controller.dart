import 'package:bonfire/bonfire.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/services.dart';

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
/// on 23/02/22
///

class KnightController extends StateController<Knight> {
  double stamina = 100;
  double attack = 20;
  bool canShowEmote = true;
  bool showedDialog = false;
  bool executingRangeAttack = false;
  double radAngleRangeAttack = 0;

  @override
  void update(double dt, Knight component) {
    bool seeEnemyInterval = component.checkInterval('seeEnemy', 250, dt);
    if (seeEnemyInterval) {
      component.seeEnemy(
        radiusVision: component.width * 4,
        notObserved: _handleNotObserveEnemy,
        observed: (enemies) => _handleObserveEnemy(enemies.first),
      );
    }

    bool execRangeAttackInterval = component.checkInterval(
      'ATTACK_RANGE',
      150,
      dt,
    );
    if (executingRangeAttack && execRangeAttackInterval) {
      if (stamina > 10) {
        _decrementStamina(10);
        component.execRangeAttack(radAngleRangeAttack, attack / 2);
      }
    }
    _verifyStamina(dt);
  }

  void handleJoystickAction(JoystickActionEvent event) {
    if (event.event == ActionEvent.DOWN) {
      if (event.id == LogicalKeyboardKey.space.keyId ||
          event.id == PlayerAttackType.attackMelee) {
        if (stamina > 15) {
          _decrementStamina(15);
          component?.execMeleeAttack(attack);
        }
      }
    }

    if (event.id == PlayerAttackType.attackRange) {
      if (event.event == ActionEvent.MOVE) {
        executingRangeAttack = true;
        radAngleRangeAttack = event.radAngle;
      }
      if (event.event == ActionEvent.UP) {
        executingRangeAttack = false;
      }
      component?.execEnableBGRangeAttack(executingRangeAttack, event.radAngle);
    }
  }

  void _handleObserveEnemy(Enemy enemy) {
    if (canShowEmote) {
      canShowEmote = false;
      component?.execShowEmote();
    }
    if (!showedDialog) {
      showedDialog = true;
      component?.execShowTalk(enemy);
    }
  }

  void _handleNotObserveEnemy() {
    canShowEmote = true;
  }

  void _verifyStamina(double dt) {
    if (stamina < 100 &&
        component?.checkInterval('INCREMENT_STAMINA', 100, dt) == true) {
      stamina += 2;
      if (stamina > 100) {
        stamina = 100;
      }
    }
    component?.updateStamina(stamina);
  }

  void _decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
    component?.updateStamina(stamina);
  }

  void onReceiveDamage(double damage) {
    component?.execShowDamage(damage);
  }
}
