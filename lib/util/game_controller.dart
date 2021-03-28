import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:bonfire/util/camera/camera.dart';
import 'package:flame/components/mixins/has_game_ref.dart';

abstract class GameListener {
  void updateGame();
  void changeCountLiveEnemies(int count);
}

class GameController with HasGameRef<BonfireGame> {
  GameListener _gameListener;
  int _lastCountLiveEnemies = 0;

  void addGameComponent(GameComponent component) {
    gameRef.addGameComponent(component);
  }

  void setListener(GameListener listener) {
    _gameListener = listener;
  }

  void notifyListeners() {
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

  Iterable<GameDecoration> get visibleDecorations =>
      gameRef.visibleDecorations();
  Iterable<GameDecoration> get allDecorations => gameRef.decorations();
  Iterable<Enemy> get visibleEnemies => gameRef.visibleEnemies();
  Iterable<Enemy> get livingEnemies => gameRef.livingEnemies();
  Iterable<GameComponent> get visibleComponents => gameRef.visibleComponents();
  Player get player => gameRef.player;
  Camera get camera => gameRef.gameCamera;
}
