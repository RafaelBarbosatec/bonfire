import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';

import 'shader_util.dart';

export 'shader_setter.dart';

mixin UseShader on PositionComponent {
  ui.FragmentShader? shader;
  double shaderCanvasScale = 1;
  bool shaderComponentStatic = false;
  ui.Image? _snapshot;

  double _shaderTime = 0;
  bool get _runShader => shader != null && _canSee;
  bool get _canSee {
    if (this is GameComponent) {
      return (this as GameComponent).isVisible;
    }
    return true;
  }

  @override
  void update(double dt) {
    if (_runShader) {
      _shaderTime += dt;
      shader?.setFloat(0, _shaderTime);
      shader?.setFloat(1, width);
      shader?.setFloat(2, height);
      if (_shaderTime > 100000000) {
        _shaderTime = 0;
      }
    }
    super.update(dt);
  }

  @override
  void renderTree(ui.Canvas canvas) {
    if (_runShader) {
      decorator.applyChain(
        (decoratorCanvas) {
          _applyShader(
            decoratorCanvas,
            (recorderCanvas) {
              render(recorderCanvas);
              for (var c in children) {
                c.renderTree(recorderCanvas);
              }
            },
          );
        },
        canvas,
      );
    } else {
      super.renderTree(canvas);
    }
  }

  void _applyShader(ui.Canvas canvas, Function(ui.Canvas canvas) record) {
    _snapshot = ShaderUtils.renderShader(
      shader: shader,
      canvas: canvas,
      record: record,
      size: size,
      shaderCanvasScale: shaderCanvasScale,
      shaderComponentStatic: shaderComponentStatic,
      snapshot: _snapshot,
    );
  }
}
