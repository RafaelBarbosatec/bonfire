import 'dart:ui' as ui;
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

abstract class ShaderUtils {
  static ui.Image renderShader({
    required ui.FragmentShader? shader,
    required ui.Canvas canvas,
    required Function(ui.Canvas canvas) record,
    required Vector2 size,
    double shaderCanvasScale = 1.0,
    bool shaderComponentStatic = false,
    ui.Image? snapshot,
  }) {
    {
      ui.Image? innerSnapshot = snapshot;
      ui.PictureRecorder recorder = ui.PictureRecorder();
      ui.Canvas canvasRecorder = ui.Canvas(recorder);
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

      canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, size.x, size.y),
        ui.Paint()
        ..color = const Color(0xFFFFFFFF)
        ..shader = shader!,
      );
      return innerSnapshot;
    }
  }
}
