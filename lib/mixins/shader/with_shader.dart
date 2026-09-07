import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';

export 'shader_api.dart';
export 'shader_setter.dart';

/// Mixin that applies a fragment shader over a component.
///
/// Access shader functionality through the [shader] API object:
/// ```dart
/// class MyLayer extends PositionComponent with WithShader {
///   @override
///   Future<void> onLoad() async {
///     super.onLoad();
///     shader.shader = await loadFragmentShader(...);
///     shader.canvasScale = 2;
///     shader.componentStatic = true;
///   }
/// }
/// ```
mixin WithShader on PositionComponent {
  late final ShaderApi shader = ShaderApi(this);

  @override
  void update(double dt) {
    shader.update(dt);
    super.update(dt);
  }

  @override
  void renderTree(ui.Canvas canvas) {
    final rendered = shader.render(canvas);
    if (!rendered) {
      super.renderTree(canvas);
    }
  }
}
