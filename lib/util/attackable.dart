import 'package:flutter/widgets.dart';

mixin Attackable {
  bool isAttackablePlayer = false;
  bool isAttackableEnemy = false;
  void receiveDamage(double damage, int from);
  Rect rectAttackable();
}
