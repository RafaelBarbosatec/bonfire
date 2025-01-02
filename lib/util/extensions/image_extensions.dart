import 'dart:math';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';

extension BonfireImageExtension on Image {
  SpriteAnimation getAnimation({
    required Vector2 size,
    required int amount,
    Vector2? position,
    double stepTime = 0.1,
    bool loop = true,
  }) {
    return SpriteAnimation.fromFrameData(
      this,
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: stepTime,
        textureSize: size,
        loop: loop,
        texturePosition: position,
      ),
    );
  }

  Sprite getSprite({
    Vector2? position,
    Vector2? size,
  }) {
    return Sprite(
      this,
      srcPosition: position,
      srcSize: size,
    );
  }

  /// Do merge image. Overlaying the images
  /// @deprecated Use [ImageComposition]
  Future<Image> overlap(Image other) {
    final recorder = PictureRecorder();
    final paint = Paint();
    final canvas = Canvas(recorder);
    final totalWidth = max(width, other.width);
    final totalHeight = max(height, other.height);
    canvas.drawImage(this, Offset.zero, paint);
    canvas.drawImage(other, Offset.zero, paint);
    return recorder.endRecording().toImage(totalWidth, totalHeight);
  }

  /// Do merge image list. Overlaying the images
  Future<Image> overlapList(List<Image> others) {
    final recorder = PictureRecorder();
    final paint = Paint();
    final canvas = Canvas(recorder);
    var totalWidth = width;
    var totalHeight = height;
    canvas.drawImage(this, Offset.zero, paint);
    for (final i in others) {
      totalWidth = max(totalWidth, i.width);
      totalHeight = max(totalHeight, i.height);
      canvas.drawImage(i, Offset.zero, paint);
    }
    return recorder.endRecording().toImage(totalWidth, totalHeight);
  }

  // flip the frames horizontally
  Future<Image> flipAnimation({required Vector2 size, required int count}) {
    final recorder = PictureRecorder();
    final paint = Paint();
    final canvas = Canvas(recorder);

    canvas.translate(width / 2, height / 2);
    canvas.scale(-1, 1);
    canvas.translate(-width / 2, -height / 2);
    var indexAux = 0;
    for (var i = count - 1; i >= 0; i--) {
      final dstPosition = Vector2(size.x * i, 0);
      final srcPosition = Vector2(size.x * indexAux, 0);
      canvas.drawImageRect(
        this,
        Rect.fromLTWH(srcPosition.x, srcPosition.y, size.x, size.y),
        Rect.fromLTWH(dstPosition.x, dstPosition.y, size.x, size.y),
        paint,
      );
      indexAux++;
    }

    return recorder.endRecording().toImage(width, height);
  }
}
