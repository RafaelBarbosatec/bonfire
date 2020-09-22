import 'package:bonfire/base/game_component.dart';
import 'package:flutter/widgets.dart';

mixin Attackable on GameComponent {
  bool isAttackablePlayer = false;
  bool isAttackableEnemy = false;
  void receiveDamage(double damage, dynamic from);
  Rect rectAttackable();
}
