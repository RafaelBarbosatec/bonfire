import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a column-major canvas transform (`Canvas.getTransform` layout).
List<double> _transform({
  double scaleX = 1,
  double scaleY = 1,
  double translationX = 0,
  double translationY = 0,
  double rotation = 0,
}) {
  final matrix = List<double>.filled(16, 0);
  matrix[0] = scaleX;
  matrix[5] = scaleY;
  matrix[10] = 1;
  matrix[15] = 1;
  if (rotation != 0) {
    matrix[1] = rotation;
    matrix[4] = -rotation;
  }
  matrix[12] = translationX;
  matrix[13] = translationY;
  return matrix;
}

void main() {
  group('TileLayerComponent.devicePixelSnapOffset', () {
    test('moves a fractional translation onto the pixel edge', () {
      final snap = TileLayerComponent.devicePixelSnapOffset(
        _transform(translationX: 10.4, translationY: -3.25),
        1,
      );

      expect(snap, isNotNull);
      expect(snap!.x, closeTo(-0.4, 1e-9));
      expect(snap.y, closeTo(0.25, 1e-9));
    });

    test('accounts for the zoom and the device pixel ratio', () {
      // 10.4 logical * 2 dpr = 20.8 device pixels: 0.8 of a device pixel to
      // remove, which is 0.8 / (2 zoom * 2 dpr) = 0.2 in world units.
      final snap = TileLayerComponent.devicePixelSnapOffset(
        _transform(scaleX: 2, scaleY: 2, translationX: 10.4, translationY: 20),
        2,
      );

      expect(snap, isNotNull);
      expect(snap!.x, closeTo(-0.2, 1e-9));
      expect(snap.y, 0);
    });

    test('returns null when the translation already lands on a pixel', () {
      final snap = TileLayerComponent.devicePixelSnapOffset(
        _transform(translationX: 12, translationY: -7),
        1,
      );

      expect(snap, isNull);
    });

    test('returns null on a rotated camera', () {
      // A rotated canvas has no single device-pixel axis to snap to.
      final snap = TileLayerComponent.devicePixelSnapOffset(
        _transform(translationX: 10.4, rotation: 0.3),
        1,
      );

      expect(snap, isNull);
    });

    test('returns null for a degenerate transform or ratio', () {
      expect(
        TileLayerComponent.devicePixelSnapOffset(
          _transform(scaleX: 0, translationX: 10.4),
          1,
        ),
        isNull,
      );
      expect(
        TileLayerComponent.devicePixelSnapOffset(
          _transform(translationX: 10.4),
          0,
        ),
        isNull,
      );
    });
  });

  group('TileLayerComponent.pixelPerfect', () {
    test('is on by default and turns antialiasing off', () {
      final layer = TileLayerComponent(id: 0, tiles: []);

      expect(layer.pixelPerfect, isTrue);
      expect(layer.paint.isAntiAlias, isFalse);
    });

    test('can be turned off, restoring antialiasing', () {
      final layer = TileLayerComponent(id: 0, tiles: []);

      layer.pixelPerfect = false;
      expect(layer.paint.isAntiAlias, isTrue);

      layer.pixelPerfect = true;
      expect(layer.paint.isAntiAlias, isFalse);
    });

    test('the constructor flag is respected', () {
      final layer = TileLayerComponent(
        id: 0,
        tiles: [],
        pixelPerfect: false,
      );

      expect(layer.pixelPerfect, isFalse);
      expect(layer.paint.isAntiAlias, isTrue);
    });
  });
}
