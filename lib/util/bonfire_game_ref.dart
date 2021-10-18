import 'package:bonfire/base/base_game.dart';
import 'package:flame/components.dart';

mixin BonfireHasGameRef<T extends BaseGame> {
  T? _gameRef;

  T get gameRef {
    final ref = _gameRef;
    if (ref == null) {
      throw 'Accessing gameRef before the component was added to the game!';
    }
    return ref;
  }

  bool get hasGameRef => _gameRef != null;

  set gameRef(T gameRef) {
    _gameRef = gameRef;
    if (this is Component) {
      (this as Component)
          .children
          .whereType<BonfireHasGameRef<T>>()
          .forEach((e) => e.gameRef = gameRef);
    }
  }
}
