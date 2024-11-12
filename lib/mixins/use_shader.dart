import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/palette.dart';

mixin UseShader on PositionComponent {
  ui.FragmentShader? shader;
  double shaderCanvasScale = 1;
  ui.Paint? _paintShader;
  bool shaderComponentStatic = false;
  ui.Image? _snapshot;

  double _shaderTime = 0;
  bool get _runShader => shader != null;

  @override
  void update(double dt) {
    if (_runShader) {
      _shaderTime += dt;
    }
    super.update(dt);
  }

  @override
  void renderTree(ui.Canvas canvas) {
    if (_runShader) {
      ui.PictureRecorder recorder = ui.PictureRecorder();

      ui.Canvas canvasRecorder = ui.Canvas(recorder);
      canvasRecorder.scale(shaderCanvasScale);
      super.renderTree(canvasRecorder);

      if (shaderComponentStatic) {
        _snapshot ??= recorder.endRecording().toImageSync(
              (width * shaderCanvasScale).floor(),
              (height * shaderCanvasScale).floor(),
            );
      } else {
        _snapshot = recorder.endRecording().toImageSync(
              (width * shaderCanvasScale).floor(),
              (height * shaderCanvasScale).floor(),
            );
      }

      _paintShader ??= ui.Paint()..color = const Color(0xFFFFFFFF);
      shader!.setFloat(0, _shaderTime);
      shader!.setFloat(1, width);
      shader!.setFloat(2, height);
      shader!.setImageSampler(0, _snapshot!);

      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, width, height),
        _paintShader!..shader = shader!,
      );
    } else {
      super.renderTree(canvas);
    }
  }

  // @override
  // void render(ui.Canvas canvas) {
  //   if (_runShader) {
  //     ui.PictureRecorder recorder = ui.PictureRecorder();

  //     ui.Canvas canvasRecorder = ui.Canvas(recorder);
  //     canvasRecorder.scale(shaderCanvasScale);
  //     super.render(canvasRecorder);

  //     if (shaderComponentStatic) {
  //       _snapshot ??= recorder.endRecording().toImageSync(
  //             (width * shaderCanvasScale).floor(),
  //             (height * shaderCanvasScale).floor(),
  //           );
  //     } else {
  //       _snapshot = recorder.endRecording().toImageSync(
  //             (width * shaderCanvasScale).floor(),
  //             (height * shaderCanvasScale).floor(),
  //           );
  //     }

  //     _paintShader ??= ui.Paint()..color = const Color(0xFFFFFFFF);
  //     shader!.setFloat(0, _shaderTime);
  //     shader!.setFloat(1, width);
  //     shader!.setFloat(2, height);
  //     shader!.setImageSampler(0, _snapshot!);

  //     canvas.drawRect(
  //       ui.Rect.fromLTWH(0, 0, width, height),
  //       _paintShader!..shader = shader!,
  //     );
  //   } else {
  //     super.render(canvas);
  //   }
  // }
}
