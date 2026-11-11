import 'package:bonfire/bonfire.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LightingOccluder', () {
    test('rect creates four points and the matching bounds', () {
      final occluder =
          LightingOccluder.rect(const Rect.fromLTWH(10, 20, 30, 40));

      expect(occluder.points, hasLength(4));
      expect(occluder.bounds, const Rect.fromLTWH(10, 20, 30, 40));
      expect(occluder.points.first, Vector2(10, 20));
      expect(occluder.points.last, Vector2(10, 60));
    });

    test('centered creates a rect around the center', () {
      final occluder =
          LightingOccluder.centered(Vector2(50, 50), Vector2(10, 20));

      expect(occluder.bounds, const Rect.fromLTWH(45, 40, 10, 20));
    });

    test('copies the given points', () {
      final points = [
        Vector2(0, 0),
        Vector2(10, 0),
        Vector2(10, 10),
      ];
      final occluder = LightingOccluder(points);

      points.first.setValues(999, 999);

      expect(occluder.points.first, Vector2.zero());
    });
  });

  group('pointInPolygon', () {
    final square = [
      Vector2(0, 0),
      Vector2(10, 0),
      Vector2(10, 10),
      Vector2(0, 10),
    ];

    test('detects points inside and outside', () {
      expect(pointInPolygon(Vector2(5, 5), square), isTrue);
      expect(pointInPolygon(Vector2(15, 5), square), isFalse);
      expect(pointInPolygon(Vector2(-1, -1), square), isFalse);
    });

    test('handles concave polygons', () {
      final concave = [
        Vector2(0, 0),
        Vector2(10, 0),
        Vector2(10, 10),
        Vector2(5, 5),
        Vector2(0, 10),
      ];

      expect(pointInPolygon(Vector2(5, 2), concave), isTrue);
      // Inside the bounding box, but in the notch cut out of the bottom.
      expect(pointInPolygon(Vector2(8, 9), concave), isFalse);
    });
  });

  group('computeVisibilityPolygon', () {
    test('without occluders every point stays on the radius', () {
      final polygon = computeVisibilityPolygon(
        center: Vector2.zero(),
        radius: 100,
        occluders: const [],
        rays: 32,
      );

      expect(polygon, hasLength(32));
      for (final point in polygon) {
        expect(point.length, closeTo(100, 1e-3));
      }
    });

    test('a wall blocks everything behind it', () {
      final wall =
          LightingOccluder.rect(const Rect.fromLTRB(50, -200, 60, 200));

      final polygon = computeVisibilityPolygon(
        center: Vector2.zero(),
        radius: 100,
        occluders: [wall],
        rays: 32,
      );

      expect(polygon, isNotEmpty);

      for (final point in polygon) {
        expect(
          point.x,
          lessThanOrEqualTo(50 + 1e-6),
          reason: 'A point reached behind the wall: $point',
        );
      }

      // At least one ray stops exactly on the wall face.
      expect(
        polygon.any((point) => (point.x - 50).abs() < 1e-6),
        isTrue,
      );
    });

    test('a light inside an occluder is fully blocked', () {
      final wall = LightingOccluder.rect(const Rect.fromLTRB(-20, -20, 20, 20));

      final polygon = computeVisibilityPolygon(
        center: Vector2.zero(),
        radius: 100,
        occluders: [wall],
      );

      expect(polygon, isEmpty);
    });

    test('occluders outside the radius are ignored', () {
      final farWall =
          LightingOccluder.rect(const Rect.fromLTRB(500, -20, 520, 20));

      final polygon = computeVisibilityPolygon(
        center: Vector2.zero(),
        radius: 100,
        occluders: [farWall],
        rays: 16,
      );

      expect(polygon, hasLength(16));
      for (final point in polygon) {
        expect(point.length, closeTo(100, 1e-3));
      }
    });

    test('returns nothing for a light without reach', () {
      expect(
        computeVisibilityPolygon(
          center: Vector2.zero(),
          radius: 0,
          occluders: const [],
        ),
        isEmpty,
      );
    });

    test('higher quality adds more points', () {
      final wall = LightingOccluder.rect(const Rect.fromLTRB(50, -20, 60, 20));

      final low = computeVisibilityPolygon(
        center: Vector2.zero(),
        radius: 100,
        occluders: [wall],
        rays: LightingQuality.low.shadowRays,
      );
      final high = computeVisibilityPolygon(
        center: Vector2.zero(),
        radius: 100,
        occluders: [wall],
        rays: LightingQuality.high.shadowRays,
      );

      expect(high.length, greaterThan(low.length));
    });
  });

  group('LightingConfig shadows', () {
    test('castShadows is disabled by default', () {
      final config = LightingConfig(radius: 40, color: Colors.white);

      expect(config.castShadows, isFalse);
    });

    test('copyWith preserves castShadows', () {
      final config = LightingConfig(
        radius: 40,
        color: Colors.white,
        castShadows: true,
      );

      expect(config.copyWith(radius: 80).castShadows, isTrue);
      expect(config.copyWith(castShadows: false).castShadows, isFalse);
    });

    test('lerpTo switches castShadows at the middle of the transition', () {
      final from = LightingConfig(radius: 10, color: Colors.white);
      final to = LightingConfig(
        radius: 20,
        color: Colors.white,
        castShadows: true,
      );

      expect(from.lerpTo(to, 0.25).castShadows, isFalse);
      expect(from.lerpTo(to, 0.75).castShadows, isTrue);
    });
  });

  group('LightingType shapes', () {
    test('rect keeps the configured size', () {
      final type = LightingType.rect(Vector2(32, 16));

      expect(type, isA<RectLightingType>());
      expect((type as RectLightingType).size, Vector2(32, 16));
    });

    test('polygon copies the given points', () {
      final points = [
        Vector2(0, -10),
        Vector2(10, 0),
        Vector2(0, 10),
      ];
      final type = LightingType.polygon(points);

      points.first.setValues(99, 99);

      expect(type, isA<PolygonLightingType>());
      expect((type as PolygonLightingType).points.first, Vector2(0, -10));
    });
  });

  group('LightingQuality', () {
    test('ordered from the cheapest to the most expensive', () {
      expect(
        LightingQuality.low.shadowRays,
        lessThan(LightingQuality.medium.shadowRays),
      );
      expect(
        LightingQuality.medium.shadowRays,
        lessThan(LightingQuality.high.shadowRays),
      );
    });
  });

  group('LightingPreset', () {
    test('day has no ambient darkness', () {
      expect(LightingPreset.day.isDay, isTrue);
      expect(LightingPreset.day.ambient.a, 0);
    });

    test('night and dungeon are dark', () {
      expect(LightingPreset.night.isDay, isFalse);
      expect(LightingPreset.night.ambient.a, greaterThan(0.8));
      expect(LightingPreset.dungeon.ambient.a, greaterThan(0.8));
    });
  });

  group('LightingComponent occluders', () {
    test('adds and removes occluders', () {
      final component = LightingComponent();
      final occluder = LightingOccluder.rect(const Rect.fromLTWH(0, 0, 10, 10));

      expect(component.occluders, isEmpty);
      expect(component.addOccluder(occluder), same(occluder));
      expect(component.occluders, [occluder]);

      expect(component.removeOccluder(occluder), isTrue);
      expect(component.removeOccluder(occluder), isFalse);
    });

    test('quality and debug have safe defaults', () {
      final component = LightingComponent();

      expect(component.quality, LightingQuality.medium);
      expect(component.debug, isFalse);
    });
  });
}
