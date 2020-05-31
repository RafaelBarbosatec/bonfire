import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/rpg_game.dart';
import 'package:bonfire/util/camera.dart';
import 'package:flame/components/component.dart';

abstract class GameListener {
  void updateGame();
  void changeCountLiveEnemies(int count);
}

class GameController {
  Timer _timerListener;
  int frequencyListener = 1000;
  GameListener _gameListener;
  RPGGame _game;
  int _lastCountLiveEnemies = 0;

  void setGame(RPGGame game) {
    _game = game;
    _lastCountLiveEnemies = _game.livingEnemies().length;
  }

  void addEnemy(Enemy enemy) {
    _game.addEnemy(enemy);
  }

  void addDecoration(GameDecoration decoration) {
    _game.addDecoration(decoration);
  }

  void addComponent(Component component) {
    _game.add(component);
  }

  void setListener(GameListener listener) {
    _gameListener = listener;
  }

  void notifyListeners() {
    if (_timerListener == null) {
      _timerListener = Timer(
        Duration(milliseconds: frequencyListener),
        () => _timerListener = null,
      );

      bool notifyChangeEnemy = false;
      int countLive = livingEnemies.length;

      if (_lastCountLiveEnemies != countLive) {
        _lastCountLiveEnemies = countLive;
        notifyChangeEnemy = true;
      }
      if (_gameListener != null) {
        _gameListener.updateGame();
        if (notifyChangeEnemy)
          _gameListener.changeCountLiveEnemies(_lastCountLiveEnemies);
      }
    }
  }

  Iterable<GameDecoration> get visibleDecorations => _game.visibleDecorations();
  Iterable<GameDecoration> get allDecorations => _game.decorations();
  Iterable<Enemy> get visibleEnemies => _game.visibleEnemies();
  Iterable<Enemy> get livingEnemies => _game.livingEnemies();
  Player get player => _game.player;
  Camera get camera => _game.gameCamera;
}
