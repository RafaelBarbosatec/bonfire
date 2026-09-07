import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/mixins/shader/shader_util.dart';

/// API that handles fragment shader application over a component.
class ShaderApi {
  final PositionComponent _comp;

  ui.FragmentShader? fragment;
  double canvasScale = 1;
  bool componentStatic = false;

  ui.Image? _snapshot;
  ui.Paint? _paint;
  double _time = 0;

  ShaderApi(this._comp);

  bool get _run => fragment != null && _canSee;

  bool get _canSee {
    if (_comp is GameComponent) {
      return _comp.isVisible;
    }
    return true;
  }

  /// Updates shader time and basic uniforms.
  void update(double dt) {
    if (_run) {
      _time += dt;
      fragment?.setFloat(0, _time);
      fragment?.setFloat(1, _comp.width);
      fragment?.setFloat(2, _comp.height);
      if (_time > 100000000) {
        _time = 0;
      }
    }
  }

  /// Renders the component and its children through the shader.
  ///
  /// Returns `true` if the shader was applied, `false` otherwise.
  bool render(ui.Canvas canvas) {
    if (_run) {
      _comp.decorator.applyChain(
        (decoratorCanvas) {
          _applyShader(
            decoratorCanvas,
            (recorderCanvas) {
              _comp.render(recorderCanvas);
              for (final c in _comp.children) {
                c.renderTree(recorderCanvas);
              }
            },
          );
        },
        canvas,
      );
      return true;
    }
    return false;
  }

  void _applyShader(ui.Canvas canvas, Function(ui.Canvas canvas) record) {
    _paint ??= ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    _snapshot = ShaderUtils.renderShader(
      shader: fragment,
      canvas: canvas,
      record: record,
      size: _comp.size,
      paint: _paint!,
      shaderCanvasScale: canvasScale,
      shaderComponentStatic: componentStatic,
      snapshot: _snapshot,
    );
  }
}
