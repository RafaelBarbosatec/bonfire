import 'package:bonfire/base/bonfire_game_interface.dart';
import 'package:flame/components.dart';

mixin BonfireHasGameRef on Component {
  BonfireGameInterface? _gameRef;

  BonfireGameInterface get gameRef {
    if (_gameRef == null) {
      var c = parent;
      while (c != null) {
        if (c is BonfireHasGameRef) {
          _gameRef = c.gameRef;
          return _gameRef!;
        } else if (c is BonfireGameInterface) {
          _gameRef = c as BonfireGameInterface;
          return _gameRef!;
        } else {
          c = c.parent;
        }
      }
      throw StateError(
        'Cannot find reference $BonfireGameInterface in the component tree',
      );
    }
    return _gameRef!;
  }

  bool get hasGameRef => _getGameRef() != null;

  BonfireGameInterface? _getGameRef() {
    if (_gameRef == null) {
      var c = parent;
      while (c != null) {
        if (c is BonfireHasGameRef) {
          _gameRef = c.gameRef;
          return _gameRef!;
        } else if (c is BonfireGameInterface) {
          _gameRef = c as BonfireGameInterface;
          return _gameRef!;
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
