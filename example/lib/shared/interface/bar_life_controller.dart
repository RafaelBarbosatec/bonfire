import 'package:flutter/material.dart';

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
class BarLifeController extends ChangeNotifier {
  static final BarLifeController _singleton = BarLifeController._internal();

  factory BarLifeController() {
    return _singleton;
  }

  BarLifeController._internal();

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
    _life = _maxLife = maxLife;
    _stamina = _maxStamina = maxStamina;
    notifyListeners();
  }

  void increaseStamina(int value) {
    stamina += value;
    if (stamina > 100) {
      stamina = 100;
    }
  }

  void decrementStamina(int value) {
    stamina -= value;
    if (stamina < 0) {
      stamina = 0;
    }
  }

  void updateLife(double life) {
    if (this.life != life) {
      this.life = life;
    }
  }
}
