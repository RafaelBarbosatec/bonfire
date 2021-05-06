import 'package:bonfire/base/bonfire_game.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/camera.dart';
import 'package:bonfire/decoration/decoration.dart';
import 'package:bonfire/enemy/enemy.dart';
import 'package:flame/components.dart';

abstract class GameListener {
  void updateGame();
  void changeCountLiveEnemies(int count);
}

class GameController with HasGameRef<BonfireGame> {
  GameListener? _gameListener;
  int _lastCountLiveEnemies = 0;

  void addGameComponent(GameComponent component) {
    gameRef.addGameComponent(component);
  }

  void setListener(GameListener listener) {
    _gameListener = listener;
  }

  void notifyListeners() {
    if (!hasGameRef) return;
    bool notifyChangeEnemy = false;
    int countLive = livingEnemies?.length ?? 0;

    if (_lastCountLiveEnemies != countLive) {
      _lastCountLiveEnemies = countLive;
      notifyChangeEnemy = true;
    }
    if (_gameListener != null) {
      _gameListener?.updateGame();
      if (notifyChangeEnemy)
        _gameListener?.changeCountLiveEnemies(_lastCountLiveEnemies);
    }
  }

  Iterable<GameDecoration>? get visibleDecorations {
    return gameRef.visibleDecorations();
  }

  Iterable<GameDecoration>? get allDecorations {
    return gameRef.decorations();
  }

  Iterable<Enemy>? get visibleEnemies {
    return gameRef.visibleEnemies();
  }

  Iterable<Enemy>? get livingEnemies {
    return gameRef.livingEnemies();
  }

  Iterable<GameComponent>? get visibleComponents {
    return gameRef.visibleComponents();
  }

  Player? get player {
    return gameRef.player;
  }

  Camera? get camera {
    return gameRef.camera;
  }
}
