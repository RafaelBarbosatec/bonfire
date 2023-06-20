import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:flame/components.dart';

mixin BonfireHasGameRef on Component {
  BonfireGameInterface? _gameRef;

  BonfireGameInterface get gameRef {
    final gameR = _getGameRef();
    if (gameR == null) {
      throw StateError(
        'Cannot find reference $BonfireGameInterface in the component tree',
      );
    } else {
      return gameR;
    }
  }

  bool get hasGameRef => _getGameRef() != null;

  BonfireGameInterface? _getGameRef() {
    if (_gameRef == null) {
      var c = parent;
      while (c != null) {
        if (c is BonfireHasGameRef) {
          return _gameRef = c.gameRef;
        } else if (c is BonfireGameInterface) {
          return _gameRef = c as BonfireGameInterface;
        } else {
          c = c.parent;
        }
      }
    }
    return _gameRef;
  }

  set gameRef(BonfireGameInterface gameRef) {
    _gameRef = gameRef;
    children.whereType<BonfireHasGameRef>().forEach((e) => e.gameRef = gameRef);
  }

  @override
  void onRemove() {
    super.onRemove();
    _gameRef = null;
  }
}
