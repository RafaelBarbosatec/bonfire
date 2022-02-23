import 'package:bonfire/bonfire.dart';
import 'package:example/shared/player/knight.dart';
import 'package:flutter/services.dart';

import 'knight_events.dart';

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

class KnightController extends GameComponentController<Knight> {
  bool canShowEmote = true;
  bool showedDialog = false;

  KnightController() {
    on((OnInteractJoystick event) => _handleJoystick(event));
    on((OnDie event) => sendEvent(ExecDie()));
    on((OnObserveEnemy event) => _handleObserveEnemy(event));
    on((OnNotObserveEnemy event) => _handleNotObserveEnemy());
  }

  void _handleJoystick(OnInteractJoystick event) {
    if (event.action == ActionEvent.DOWN) {
      if (event.id == LogicalKeyboardKey.space.keyId ||
          event.id == PlayerAttackType.AttackMelee) {
        sendEvent(ExecMeleeAttack());
      }
    }

    if (event.id == PlayerAttackType.AttackRange) {
      if (event.action == ActionEvent.MOVE) {
        sendEvent(ExecRangeAttack(true, radAngle: event.radAngle));
      }
      if (event.action == ActionEvent.UP) {
        sendEvent(ExecRangeAttack(false));
      }
    }
  }

  void _handleObserveEnemy(OnObserveEnemy event) {
    if (canShowEmote) {
      canShowEmote = false;
      sendEvent(ExecShowEmote());
    }
    if (!showedDialog) {
      showedDialog = true;
      sendEvent(ExecShowTalk(event.enemy));
    }
  }

  void _handleNotObserveEnemy() {
    canShowEmote = true;
  }
}
