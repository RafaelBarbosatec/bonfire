import 'package:bonfire/bonfire.dart';
import 'package:example/pages/collision/collision_component.dart';

class AddCollisionComponent extends GameComponent with TapGesture {
  @override
  void onTap() {}

  @override
  void onTapDownScreen(GestureEvent event) {
    gameRef.add(
      CollisionComponent(
        position: event.worldPosition,
        isCircle: true,
      ),
    );
    super.onTapDownScreen(event);
  }

  @override
  bool get isVisible => true;
}
