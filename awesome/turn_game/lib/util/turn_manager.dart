import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:turn_game/game.dart';
import 'package:turn_game/util/player_ally.dart';
import 'package:turn_game/util/player_enemy.dart';

enum OwnerTurn { ally, enemy }

class TurnManager extends GameComponent with ChangeNotifier {
  static final TurnManager instance = TurnManager._();

  TurnManager._();

  // ignore: constant_identifier_names
  static const MAX_ACTION = 2;
  OwnerTurn ownerTurn = OwnerTurn.ally;
  GameComponent? characterSelected;
  PlayerAlly? _lastAlly;
  PlayerEnemy? _lastEnemy;
  bool endGame = false;
  int _countAction = 0;
  int get countAction => _countAction;

  final IntervalTick _gameOverTick = IntervalTick(1000);

  bool selectCharacter(GameComponent? char) {
    if (ownerTurn == OwnerTurn.ally) {
      if (char is PlayerAlly) {
        characterSelected = char;
        _lastAlly = char;
        return true;
      }
    }
    if (ownerTurn == OwnerTurn.enemy) {
      if (char is PlayerEnemy) {
        characterSelected = char;
        _lastEnemy = char;
        return true;
      }
    }
    if (char == null) {
      characterSelected = null;
    }
    return false;
  }

  void chageTurn() {
    if (ownerTurn == OwnerTurn.ally) {
      _selectOneEnemy();
    } else {
      _selectOneAlly();
    }
    _countAction = 0;
    notifyListeners();
  }

  void doAction() {
    _countAction++;
    if (_countAction >= MAX_ACTION) {
      chageTurn();
    }
    notifyListeners();
  }

  bool isYourTurn(GameComponent char) => char == characterSelected;

  void _selectOneAlly() {
    ownerTurn = OwnerTurn.ally;
    if (_lastAlly == null || _lastAlly?.isDead == true) {
      final ally =
          gameRef.query<PlayerAlly>().where((element) => !element.isDead);
      if (ally.isNotEmpty) {
        _lastAlly = ally.first;
      }
    }
    _lastAlly?.onTap();
  }

  void _selectOneEnemy() {
    ownerTurn = OwnerTurn.enemy;
    if (_lastEnemy == null || _lastEnemy?.isDead == true) {
      final enemy =
          gameRef.query<PlayerEnemy>().where((element) => !element.isDead);
      if (enemy.isNotEmpty) {
        _lastEnemy = enemy.first;
      }
    }
    _lastEnemy?.onTap();
  }

  @override
  void onMount() {
    startGame();
    super.onMount();
  }

  void startGame() async {
    endGame = false;
    await Future.delayed(const Duration(milliseconds: 500));
    bool startAlly = Random().nextBool();
    if (startAlly) {
      _selectOneAlly();
    } else {
      _selectOneEnemy();
    }
    notifyListeners();
  }

  @override
  void update(double dt) {
    if (_gameOverTick.update(dt) && !endGame) {
      var enemyLife =
          gameRef.query<PlayerEnemy>().where((element) => !element.isDead);
      if (enemyLife.isEmpty) {
        endGame = true;
        _showDialog('Ally win');
      }

      var allyLife =
          gameRef.query<PlayerAlly>().where((element) => !element.isDead);
      if (allyLife.isEmpty) {
        endGame = true;
        _showDialog('Enemy win');
      }
    }
    super.update(dt);
  }

  void _showDialog(String s) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(gameRef.context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const TurnGame()),
                  (route) => false,
                );
              },
              child: const Text('Ok'),
            )
          ],
        );
      },
    );
  }
}
