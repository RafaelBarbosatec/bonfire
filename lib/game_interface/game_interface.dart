import 'dart:async';

import 'package:bonfire/bonfire.dart';

/// The way you cand raw things like life bars, stamina and settings. In another words, anything that you may add to the interface to the game.
class GameInterface extends GameComponent {
  @override
  int get priority {
    return LayerPriority.getHudInterfacePriority();
  }

  /// Used to add components in your interface like a Button.
  @override
  FutureOr<void> add(Component component) {
    if (component is InterfaceComponent) {
      removeById(component.id);
    }
    return super.add(component);
  }

  /// Used to remove component of the interface by id
  void removeById(int id) {
    if (children.isEmpty) {
      return;
    }
    removeWhere(
      (component) => component is InterfaceComponent && component.id == id,
    );
  }

  @override
  bool hasGesture() => true;
}
