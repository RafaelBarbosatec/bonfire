import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';

abstract class ShaderUtils {
  static ui.Image renderShader({
    required ui.FragmentShader? shader,
    required ui.Canvas canvas,
    required Function(ui.Canvas canvas) record,
    required Vector2 size,
    required ui.Paint paint,
    double shaderCanvasScale = 1.0,
    bool shaderComponentStatic = false,
    ui.Image? snapshot,
  }) {
    {
      var innerSnapshot = snapshot;
      final recorder = ui.PictureRecorder();
      final canvasRecorder = ui.Canvas(recorder);
      canvasRecorder.scale(shaderCanvasScale);
      record(canvasRecorder);

      if (shaderComponentStatic) {
        if (innerSnapshot == null) {
          innerSnapshot = recorder.endRecording().toImageSync(
                (size.x * shaderCanvasScale).floor(),
                (size.y * shaderCanvasScale).floor(),
              );
          shader!.setImageSampler(0, innerSnapshot);
        }
      } else {
        innerSnapshot = recorder.endRecording().toImageSync(
              (size.x * shaderCanvasScale).floor(),
              (size.y * shaderCanvasScale).floor(),
            );
        shader!.setImageSampler(0, innerSnapshot);
      }

      paint.shader = shader;

      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, size.x, size.y),
        paint,
      );
      return innerSnapshot;
    }
  }
}
