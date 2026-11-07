import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/pulse_value.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestComponent extends GameComponent {
  @override
  void update(double dt) {}

  @override
  void render(Canvas canvas) {}
}

void main() {
  group('PulseValue', () {
    test('value stays within pulseVariation', () {
      final pulse = PulseValue(
        speed: 0.5,
        pulseVariation: 0.1,
        curve: Curves.linear,
      );

      for (var i = 0; i < 400; i++) {
        pulse.update(0.016);
        expect(pulse.value, inInclusiveRange(0, 0.1));
      }
    });

    test('uses the configured curve instead of a hardcoded one', () {
      final linear = PulseValue(
        speed: 1,
        pulseVariation: 1,
        curve: Curves.linear,
      );
      final decelerate = PulseValue(
        speed: 1,
        pulseVariation: 1,
        curve: Curves.decelerate,
      );

      linear.update(0.5);
      decelerate.update(0.5);

      expect(linear.value, closeTo(0.5, 1e-9));
      expect(decelerate.value, greaterThan(linear.value));
    });

    test('keeps the historical timing: speed 0.1 takes 1s to reach 0.1', () {
      final pulse = PulseValue(
        speed: 0.1,
        pulseVariation: 0.1,
        curve: Curves.linear,
      );

      pulse.update(0.5);
      expect(pulse.value, closeTo(0.05, 1e-9));
      expect(pulse.phase, closeTo(0.5, 1e-9));

      pulse.update(0.5);
      expect(pulse.value, closeTo(0.1, 1e-9));
    });

    test('ping-pongs back to zero', () {
      final pulse = PulseValue(
        speed: 1,
        pulseVariation: 1,
        curve: Curves.linear,
      );

      pulse.update(1);
      expect(pulse.value, closeTo(1, 1e-9));

      pulse.update(1);
      expect(pulse.value, closeTo(0, 1e-9));
    });

    test('zero variation disables the pulse', () {
      final pulse = PulseValue(pulseVariation: 0)..update(1);
      expect(pulse.value, 0);
    });
  });

  group('LightingConfig', () {
    test('copyWith preserves align', () {
      final config = LightingConfig(
        radius: 100,
        color: Colors.white,
        align: Vector2(12, -8),
      );

      final copy = config.copyWith(radius: 200);

      expect(copy.radius, 200);
      expect(copy.align.x, 12);
      expect(copy.align.y, -8);
    });

    test('copyWith accepts a new align and copies it', () {
      final config = LightingConfig(radius: 100, color: Colors.white);

      final align = Vector2(5, 5);
      final copy = config.copyWith(align: align);
      align.setValues(99, 99);

      expect(copy.align.x, 5);
      expect(copy.align.y, 5);
    });

    test('copyWith preserves mode', () {
      final config = LightingConfig(
        radius: 100,
        color: Colors.white,
        mode: LightingMode.additive,
      );

      expect(config.copyWith(radius: 10).mode, LightingMode.additive);
    });

    test('blurBorder zero produces a crisp edge', () {
      final config = LightingConfig(
        radius: 100,
        color: Colors.white,
        blurBorder: 0,
      );

      expect(config.maskFilter, isNull);
    });

    test('lerpTo interpolates radius, color and align', () {
      final from = LightingConfig(
        radius: 100,
        color: const Color(0xFF000000),
        align: Vector2(0, 0),
        blurBorder: 10,
      );
      final to = LightingConfig(
        radius: 200,
        color: const Color(0xFFFFFFFF),
        align: Vector2(10, 20),
        blurBorder: 20,
      );

      final mid = from.lerpTo(to, 0.5);

      expect(mid.radius, closeTo(150, 1e-9));
      expect(mid.blurBorder, closeTo(15, 1e-9));
      expect(mid.align.x, closeTo(5, 1e-9));
      expect(mid.align.y, closeTo(10, 1e-9));
      expect(mid.color, Color.lerp(from.color, to.color, 0.5));
    });
  });

  group('LightingApi', () {
    test('animateTo interpolates the config over time', () {
      final api = LightingApi(_TestComponent())
        ..setup(LightingConfig(radius: 100, color: Colors.white));

      api.animateTo(
        LightingConfig(radius: 200, color: Colors.white),
        duration: const Duration(seconds: 1),
        curve: Curves.linear,
      );

      expect(api.isAnimating, isTrue);

      api.update(0.5);
      expect(api.config!.radius, closeTo(150, 0.5));

      api.update(0.5);
      expect(api.isAnimating, isFalse);
      expect(api.config!.radius, 200);
    });

    test('animateTo applies immediately without a current config', () {
      final api = LightingApi(_TestComponent());

      api.animateTo(LightingConfig(radius: 80, color: Colors.white));

      expect(api.isAnimating, isFalse);
      expect(api.config!.radius, 80);
    });

    test('setup cancels a running animation', () {
      final api = LightingApi(_TestComponent())
        ..setup(LightingConfig(radius: 100, color: Colors.white));

      api.animateTo(
        LightingConfig(radius: 200, color: Colors.white),
        duration: const Duration(seconds: 1),
      );
      api.setup(LightingConfig(radius: 10, color: Colors.white));
      api.update(0.5);

      expect(api.isAnimating, isFalse);
      expect(api.config!.radius, 10);
    });
  });
}
