import 'dart:async';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:example/shared/util/person_sprite_sheet.dart';

class HumanPlayer extends SimplePlayer with BlockMovementCollision, UseShader {
  HumanPlayer({
    required Vector2 position,
  }) : super(
          animation: PersonSpritesheet().simpleAnimation(),
          position: position,
          size: Vector2.all(24),
          speed: 32,
        );

  @override
  Future<void> onLoad() {
    /// Adds rectangle collision
    add(
      RectangleHitbox(
        size: size / 2,
        position: size / 4,
      ),
    );
    return super.onLoad();
  }

  @override
  void onMount() {
    Future.delayed(const Duration(seconds: 1), _addShader);
    super.onMount();
  }

  FutureOr _addShader() async {
    var program = await FragmentProgram.fromAsset('shaders/myshader.frag');
    shader = program.fragmentShader();
  }
}
