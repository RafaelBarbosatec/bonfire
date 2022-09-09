import 'package:bonfire/bonfire.dart';
import 'package:flame/game.dart';

abstract class GameListener {
  void updateGame();
  void changeCountLiveEnemies(int count);
}

class GameController extends Component with BonfireHasGameRef {
  final List<GameListener> _gameListeners = [];
  int _lastCountLiveEnemies = 0;

  void addGameComponent(GameComponent component) {
    gameRef.add(component);
  }

  void addListener(GameListener listener) {
    _gameListeners.add(listener);
  }

  void removeListener(GameListener listener) {
    _gameListeners.remove(listener);
  }

  void notifyListeners() {
    if (!hasGameRef) return;
    bool notifyChangeEnemy = false;
    int countLive = livingEnemies?.length ?? 0;

    if (_lastCountLiveEnemies != countLive) {
      _lastCountLiveEnemies = countLive;
      notifyChangeEnemy = true;
    }
    if (_gameListeners.isNotEmpty) {
      for (var element in _gameListeners) {
        element.updateGame();
        if (notifyChangeEnemy) {
          element.changeCountLiveEnemies(_lastCountLiveEnemies);
        }
      }
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
