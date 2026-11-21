import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:sprite_stack/sprite_stack.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SpriteStack.fromImage', () {
    test('splits a horizontal strip into slices', () async {
      final image = await _solidImage(width: 8, height: 2, color: 0xFF3366FF);
      final stack = SpriteStack.fromImage(image, sliceCount: 4);

      expect(stack.sliceCount, 4);
      expect(stack.sliceWidth, 2);
      expect(stack.sliceHeight, 2);
      expect(stack.sliceSize, const ui.Size(2, 2));

      stack.dispose();
    });

    test('rejects an invalid slice count', () async {
      final image = await _solidImage(width: 8, height: 2, color: 0xFFFFFFFF);

      expect(
        () => SpriteStack.fromImage(image, sliceCount: 0),
        throwsArgumentError,
      );
      expect(
        () => SpriteStack.fromImage(image, sliceCount: -3),
        throwsArgumentError,
      );

      image.dispose();
    });

    test('rejects an image width that is not divisible', () async {
      final image = await _solidImage(width: 7, height: 2, color: 0xFFFFFFFF);

      expect(
        () => SpriteStack.fromImage(image, sliceCount: 3),
        throwsArgumentError,
      );

      image.dispose();
    });
  });

  group('projection', () {
    test('squash is the sine of the pitch, clamped', () {
      expect(SpriteStack.squashFor(0), 0.08);
      expect(SpriteStack.squashFor(math.pi / 2), closeTo(1, 1e-9));
      expect(
        SpriteStack.squashFor(math.pi / 4),
        closeTo(math.sin(math.pi / 4), 1e-9),
      );
      expect(SpriteStack.squashFor(10), closeTo(1, 1e-9));
    });

    test('height adds the lifts to the squashed slice height', () async {
      final image = await _solidImage(width: 8, height: 4, color: 0xFF00FF00);
      final stack = SpriteStack.fromImage(image, sliceCount: 4);

      expect(stack.heightFor(pitch: math.pi / 2, spacing: 1), 7);
      expect(stack.heightFor(pitch: math.pi / 2, spacing: 2), 10);

      stack.dispose();
    });
  });

  group('render', () {
    test('places the bottom slice at the given position', () async {
      final image = await _solidImage(width: 4, height: 4, color: 0xFFFF0000);
      final stack = SpriteStack.fromImage(image, sliceCount: 1);

      final pixels = await _renderToPixels(
        stack,
        width: 24,
        height: 24,
        position: const ui.Offset(12, 20),
        pitch: math.pi / 2,
      );

      // Slice is 4x4, so it covers x 10..14 and y 16..20.
      expect(_pixelAt(pixels, 24, 12, 18), 0xFFFF0000);
      expect(_pixelAt(pixels, 24, 12, 15), 0x00000000);
      expect(_pixelAt(pixels, 24, 6, 18), 0x00000000);

      stack.dispose();
    });

    test('lifts every slice by spacing', () async {
      // Two slices: red on the ground, green on top.
      final image = await _twoToneImage();
      final stack = SpriteStack.fromImage(image, sliceCount: 2);

      final pixels = await _renderToPixels(
        stack,
        width: 24,
        height: 40,
        position: const ui.Offset(12, 36),
        pitch: math.pi / 2,
        spacing: 8,
      );

      // Ground slice center: y = 36 - 2 = 34. Top slice: y = 34 - 8 = 26.
      expect(_pixelAt(pixels, 24, 12, 34), 0xFFFF0000);
      expect(_pixelAt(pixels, 24, 12, 26), 0xFF00FF00);

      stack.dispose();
    });

    test('renders without throwing for a full stack', () async {
      final image =
          await _solidImage(width: 32 * 24, height: 32, color: 0xFF00FF00);
      final stack = SpriteStack.fromImage(image, sliceCount: 24);

      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder);
      stack.render(
        canvas,
        position: const ui.Offset(100, 200),
        yaw: 1.2,
        pitch: 0.6,
        scale: 4,
      );
      final picture = recorder.endRecording();
      final rendered = await picture.toImage(200, 260);

      expect(rendered.width, 200);
      expect(rendered.height, 260);

      rendered.dispose();
      picture.dispose();
      stack.dispose();
    });
  });
}

Future<ui.Image> _solidImage({
  required int width,
  required int height,
  required int color,
}) async {
  final pixels = Uint8List(width * height * 4);
  for (var i = 0; i < width * height; i++) {
    _writeColor(pixels, i * 4, color);
  }
  return _decode(pixels, width, height);
}

/// 4x4 strip with two 2x4 slices: red (ground) then green.
Future<ui.Image> _twoToneImage() async {
  const width = 4;
  const height = 4;
  final pixels = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final color = x < width ~/ 2 ? 0xFFFF0000 : 0xFF00FF00;
      _writeColor(pixels, (y * width + x) * 4, color);
    }
  }
  return _decode(pixels, width, height);
}

void _writeColor(Uint8List pixels, int offset, int argb) {
  pixels[offset] = (argb >> 16) & 0xFF; // r
  pixels[offset + 1] = (argb >> 8) & 0xFF; // g
  pixels[offset + 2] = argb & 0xFF; // b
  pixels[offset + 3] = (argb >> 24) & 0xFF; // a
}

Future<ui.Image> _decode(Uint8List pixels, int width, int height) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    width,
    height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  return completer.future;
}

Future<Uint8List> _renderToPixels(
  SpriteStack stack, {
  required int width,
  required int height,
  required ui.Offset position,
  required double pitch,
  double spacing = 1,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  stack.render(
    canvas,
    position: position,
    pitch: pitch,
    spacing: spacing,
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(width, height);
  final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);

  image.dispose();
  picture.dispose();

  return data!.buffer.asUint8List();
}

int _pixelAt(Uint8List pixels, int width, int x, int y) {
  final offset = (y * width + x) * 4;
  final r = pixels[offset];
  final g = pixels[offset + 1];
  final b = pixels[offset + 2];
  final a = pixels[offset + 3];
  return (a << 24) | (r << 16) | (g << 8) | b;
}
