import 'package:bonfire/bonfire.dart';

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

class OnInteractJoystick extends GameComponentEvent {
  final dynamic id;
  final ActionEvent action;
  final double radAngle;

  OnInteractJoystick(this.id, this.action, this.radAngle);
}

class OnDie extends GameComponentEvent {}

class OnObserveEnemy extends GameComponentEvent {
  final Enemy enemy;

  OnObserveEnemy(this.enemy);
}

class OnNotObserveEnemy extends GameComponentEvent {}

class ExecDie extends GameComponentEvent {}

class ExecMeleeAttack extends GameComponentEvent {}

class ExecRangeAttack extends GameComponentEvent {
  final bool enabled;
  final double radAngle;

  ExecRangeAttack(this.enabled, {this.radAngle = 0});
}

class ExecShowEmote extends GameComponentEvent {}

class ExecShowTalk extends GameComponentEvent {
  final GameComponent target;

  ExecShowTalk(this.target);
}
