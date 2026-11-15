import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/bonfire_camera.dart';
import 'package:bonfire/lighting/lighting_component.dart';
import 'package:flame/camera.dart';
import 'package:flutter_test/flutter_test.dart';

class _LightComponent extends GameComponent with WithLighting {
  _LightComponent(Vector2 position) {
    this.position.setFrom(position);
    size.setValues(10, 10);
  }

  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {}
}

class _FakeGame implements BonfireGameInterface {
  final List<GameComponent> lights = [];

  @override
  final BonfireCamera camera;

  _FakeGame(this.camera);

  @override
  Iterable<T> visibles<T extends GameComponent>() => lights.whereType<T>();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<ByteData> _renderCutoutLight({
  required Color ambient,
  required LightingConfig config,
  Vector2? lightPosition,
  List<LightingOccluder> occluders = const [],
  Size viewport = const Size(300, 300),
}) async {
  final camera = BonfireCamera(
    world: World(),
    viewport: MaxViewport(),
  );
  camera.viewport.size = viewport.toVector2();
  camera.viewfinder.position = viewport.toVector2() / 2;
  camera.viewfinder.zoom = 1.0;

  final game = _FakeGame(camera);
  final component = _LightComponent(
    lightPosition ?? Vector2(viewport.width / 2, viewport.height / 2),
  )..lighting.setup(config);
  game.lights.add(component);

  final lighting = LightingComponent(color: ambient);
  lighting.gameRef = game;
  for (final occluder in occluders) {
    lighting.addOccluder(occluder);
  }
  lighting.onGameResize(viewport.toVector2());
  lighting.update(0.016);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawColor(const Color(0xFFFFFFFF), ui.BlendMode.src);
  lighting.renderTree(canvas);
  final picture = recorder.endRecording();
  final image =
      await picture.toImage(viewport.width.toInt(), viewport.height.toInt());
  return (await image.toByteData())!;
}

int _redAt(ByteData data, int width, int x, int y) {
  return data.getUint8((y * width + x) * 4);
}

void main() {
  group('LightingComponent cutout rendering', () {
    test('blur falloff erases the ambient with a soft circular edge', () async {
      final data = await _renderCutoutLight(
        ambient: const Color(0xFF090253).withValues(alpha: 0.6),
        config: LightingConfig(
          color: const Color(0x00000000),
          radius: 50,
          blurBorder: 20,
        ),
      );

      const width = 300;
      // Ambient darkness over the white world:
      // 9 * 0.6 + 255 * 0.4 = 107.
      // The corner is far away from the light, so it stays ambient.
      expect(_redAt(data, width, 5, 5), inInclusiveRange(106, 108));
      // The center of the light erases the ambient and reveals the world.
      expect(_redAt(data, width, 150, 150), greaterThan(250));
      // The blur produces a soft transition between the two.
      final edge = _redAt(data, width, 150, 150 - 50);
      expect(edge, greaterThan(104));
      expect(edge, lessThan(250));
    });

    test('blur falloff keeps the soft edge when shadows are enabled', () async {
      const ambient = Color(0xFF090253);
      const width = 300;
      final config = LightingConfig(
        color: const Color(0x00000000),
        radius: 50,
        blurBorder: 20,
      );

      final withoutShadows = await _renderCutoutLight(
        ambient: ambient.withValues(alpha: 0.6),
        config: config,
      );
      final withShadows = await _renderCutoutLight(
        ambient: ambient.withValues(alpha: 0.6),
        config: config.copyWith(castShadows: true),
        occluders: [
          // Far away from the light, so it does not block any ray.
          LightingOccluder.rect(const Rect.fromLTWH(260, 260, 10, 10)),
        ],
      );

      // Sample the edge where the blur falloff is halfway: the result must
      // stay soft instead of turning into a hard circle cut at the radius.
      for (final y in [150 - 50, 150 - 60, 150 - 70]) {
        final a = _redAt(withoutShadows, width, 150, y);
        final b = _redAt(withShadows, width, 150, y);
        expect((a - b).abs(), lessThan(25), reason: 'y=$y without=$a with=$b');
      }
    });

    test('gradient falloff also erases with a soft edge', () async {
      final data = await _renderCutoutLight(
        ambient: const Color(0xFF090253).withValues(alpha: 0.6),
        config: LightingConfig(
          color: const Color(0x00000000),
          radius: 50,
          falloff: LightFalloff.smooth,
        ),
      );

      const width = 300;
      expect(_redAt(data, width, 5, 5), inInclusiveRange(106, 108));
      expect(_redAt(data, width, 150, 150), greaterThan(250));
      final edge = _redAt(data, width, 150, 150 - 40);
      expect(edge, greaterThan(104));
      expect(edge, lessThan(250));
    });
  });
}
