import 'package:bonfire/bonfire.dart';

import 'bar_life_component.dart';

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
/// on 25/02/22
class BarLifeController extends StateController<BarLifeInterface> {
  double _maxLife = 100;
  double _maxStamina = 100;
  get maxLife => _maxLife;
  get maxStamina => _maxStamina;

  double _life = 0;
  double _stamina = 0;

  double get life => _life;
  double get stamina => _stamina;

  set life(double newLife) {
    _life = newLife;
    notifyListeners();
  }

  set stamina(double newStamina) {
    _stamina = newStamina;
    notifyListeners();
  }

  void configure({required double maxLife, required double maxStamina}) {
    _maxLife = maxLife;
    _maxStamina = maxStamina;
  }

  @override
  void update(double dt, BarLifeInterface component) {}
}
