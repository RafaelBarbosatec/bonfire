import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';

mixin UseShader on PositionComponent {
  ui.FragmentShader? shader;
  double shaderCanvasScale = 1;
  ui.Paint? _paintShader;
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
      shader!.setFloat(0, _shaderTime);
      shader!.setFloat(1, width);
      shader!.setFloat(2, height);
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

  void _applyShader(ui.Canvas canvas, Function(ui.Canvas canvas) apply) {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    ui.Canvas canvasRecorder = ui.Canvas(recorder);
    canvasRecorder.scale(shaderCanvasScale);
    apply(canvasRecorder);

    if (shaderComponentStatic) {
      if (_snapshot == null) {
        _snapshot = recorder.endRecording().toImageSync(
              (width * shaderCanvasScale).floor(),
              (height * shaderCanvasScale).floor(),
            );
        shader!.setImageSampler(0, _snapshot!);
      }
    } else {
      _snapshot = recorder.endRecording().toImageSync(
            (width * shaderCanvasScale).floor(),
            (height * shaderCanvasScale).floor(),
          );
      shader!.setImageSampler(0, _snapshot!);
    }

    _paintShader ??= ui.Paint()..color = const Color(0xFFFFFFFF);

    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, width, height),
      _paintShader!..shader = shader!,
    );
  }
}
