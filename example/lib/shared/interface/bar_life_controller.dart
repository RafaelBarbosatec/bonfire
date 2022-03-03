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
/// on 25/02/22
class BarLifeController extends StateController {
  double _maxLife = 100;
  double _maxStamina = 100;
  get maxLife => _maxLife;
  get maxStamina => _maxStamina;

  double life = 0;
  double stamina = 0;

  void configure({required double maxLife, required double maxStamina}) {
    _maxLife = maxLife;
    _maxStamina = maxStamina;
  }
}
