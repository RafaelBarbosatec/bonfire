import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:flame/extensions.dart' show CanvasExtension;
import 'package:flutter/widgets.dart';

abstract class LightingInterface {
  Color? color;
  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });

  /// Animates the ambient color from fully transparent to [color].
  void fadeIn(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });

  /// Animates the ambient color to fully transparent.
  void fadeOut({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  });

  bool isEnabled();

  /// Adds a light that is not attached to a component.
  LightSource addLight(LightSource light);

  /// Removes a light previously added with [addLight].
  bool removeLight(LightSource light);

  /// Quality used to compute the shadows of lights with
  /// `LightingConfig.castShadows`.
  LightingQuality get quality;
  set quality(LightingQuality value);

  /// When `true`, draws the outline of every light, occluder and shadow
  /// silhouette. Useful to debug why a light is not reaching somewhere.
  bool get debug;
  set debug(bool value);

  /// Occluders registered through [addOccluder].
  List<LightingOccluder> get occluders;

  /// Registers a light blocker in world coordinates.
  ///
  /// Register static geometry once (walls, tiles); moving obstacles can use the
  /// `WithLightingOcclusion` mixin instead.
  LightingOccluder addOccluder(LightingOccluder occluder);

  /// Removes an occluder previously added with [addOccluder].
  bool removeOccluder(LightingOccluder occluder);

  /// Applies an ambient [preset], fading the ambient color smoothly.
  void applyPreset(
    LightingPreset preset, {
    Duration duration = const Duration(milliseconds: 900),
    Curve curve = Curves.decelerate,
  });
}

/// Layer component responsible for adding lighting to the game.
class LightingComponent extends GameComponent implements LightingInterface {
  final Paint _paintLighting = Paint();

  final List<LightSource> _lightSources = [];
  final List<LightingOccluder> _occluders = [];

  ColorTween? _tween;
  bool _containColor = false;
  LightingQuality _quality = LightingQuality.medium;
  bool _debug = false;

  Rect? bounds;
  @override
  Color? color;

  LightingComponent({this.color});

  /// Lights added through [addLight].
  List<LightSource> get lightSources => List.unmodifiable(_lightSources);

  @override
  int get priority {
    return LayerPriority.getHudLightingPriority();
  }

  @override
  LightingQuality get quality => _quality;

  @override
  set quality(LightingQuality value) {
    _quality = value;
  }

  @override
  bool get debug => _debug;

  @override
  set debug(bool value) {
    _debug = value;
  }

  @override
  List<LightingOccluder> get occluders => List.unmodifiable(_occluders);

  @override
  LightingOccluder addOccluder(LightingOccluder occluder) {
    _occluders.add(occluder);
    return occluder;
  }

  @override
  bool removeOccluder(LightingOccluder occluder) => _occluders.remove(occluder);

  @override
  void applyPreset(
    LightingPreset preset, {
    Duration duration = const Duration(milliseconds: 900),
    Curve curve = Curves.decelerate,
  }) {
    preset.apply(this, duration: duration, curve: curve);
  }

  Path getWheelPath(double wheelSize, double fromRadius, double toRadius) {
    return Path()
      ..moveTo(wheelSize, wheelSize)
      ..arcTo(
        Rect.fromCircle(
          radius: wheelSize,
          center: Offset(wheelSize, wheelSize),
        ),
        fromRadius,
        toRadius,
        false,
      )
      ..close();
  }

  Iterable<WithLighting> get _visibleLight {
    return gameRef.visibles<WithLighting>();
  }

  @override
  LightSource addLight(LightSource light) {
    _lightSources.add(light);
    return light;
  }

  @override
  bool removeLight(LightSource light) => _lightSources.remove(light);

  @override
  void renderTree(Canvas canvas) {
    final componentLights =
        _visibleLight.where(_isLightRenderable).toList(growable: false);
    final lightSources = _lightSources
        .where((light) => light.enabled && _isLightSourceVisible(light))
        .toList(growable: false);

    if (componentLights.isEmpty && lightSources.isEmpty) {
      if (_debug) {
        _renderDebug(canvas, const [], _resolveOccluders());
      }
      return;
    }

    final occluders =
        componentLights.any((light) => light.lighting.config!.castShadows) ||
                lightSources.any((light) => light.config.castShadows)
            ? _resolveOccluders()
            : const <LightingOccluder>[];

    final additive = <_PendingLight>[];
    final cutout = <_PendingLight>[];

    for (final light in componentLights) {
      final config = light.lighting.config!;
      final pending = _resolveLight(
        config: config,
        center: light.absoluteCenter + config.align,
        angle: light.lighting.angle,
        occluders: occluders,
      );
      if (pending == null) {
        continue;
      }
      (config.mode == LightingMode.additive ? additive : cutout).add(pending);
    }

    for (final light in lightSources) {
      final config = light.config;
      final pending = _resolveLight(
        config: config,
        center: light.position + config.align,
        angle: light.angle,
        occluders: occluders,
      );
      if (pending == null) {
        continue;
      }
      (config.mode == LightingMode.additive ? additive : cutout).add(pending);
    }

    // Additive lights are composited *below* the ambient darkness, so the
    // ambient color darkens them instead of the light being painted on top of
    // the night color.
    if (additive.isNotEmpty) {
      canvas.saveLayer(bounds, paint);
      canvas.save();
      _applyCameraTransform(canvas);

      for (final light in additive) {
        _renderLight(canvas, light, cutout: false);
      }

      canvas.restore();
      canvas.restore();
    }

    // A cutout light only makes sense when there is ambient darkness to erase.
    if (_containColor) {
      canvas.saveLayer(bounds, paint);
      canvas.drawColor(color!, BlendMode.dstATop);
      canvas.save();
      _applyCameraTransform(canvas);

      for (final light in cutout) {
        _renderLight(canvas, light, cutout: true);
      }

      canvas.restore();
      canvas.restore();
    }

    if (_debug) {
      _renderDebug(canvas, [...additive, ...cutout], occluders);
    }
  }

  /// Applies the same transform the camera uses to render the world.
  ///
  /// Using the viewfinder transform (instead of manually translating by the
  /// camera top-left) keeps lights aligned when the camera is rotated or when
  /// a custom anchor is used.
  void _applyCameraTransform(Canvas canvas) {
    canvas.transform2D(gameRef.camera.viewfinder.transform);
  }

  bool _isLightRenderable(WithLighting light) {
    final config = light.lighting.config;
    return config != null && light.lighting.enabled;
  }

  bool _isLightSourceVisible(LightSource light) {
    final camera = gameRef.camera;
    final radius = _shapeRadius(light.config, light.config.radiusWithEffects);
    return camera.cameraRectWithSpacing
        .inflate(radius)
        .contains(light.position.toOffset());
  }

  /// Occluders registered through [addOccluder] plus the ones provided by
  /// components with the [WithLightingOcclusion] mixin.
  List<LightingOccluder> _resolveOccluders() {
    final result = List<LightingOccluder>.of(_occluders);
    for (final component in gameRef.visibles<WithLightingOcclusion>()) {
      result.addAll(component.lightingOccluders);
    }
    return result;
  }

  @override
  void update(double dt) {
    _containColor = _containsColor();

    for (final light in _visibleLight) {
      if (_isLightRenderable(light)) {
        light.lighting.config!.update(dt);
      }
    }

    for (final light in _lightSources) {
      if (light.enabled) {
        light.config.update(dt);
      }
    }

    super.update(dt);
  }

  @override
  bool isEnabled() => _containColor;

  @override
  void animateToColor(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    _tween = ColorTween(
      begin: this.color ?? const Color(0x00000000),
      end: color,
    );

    util.generateValues(
      duration,
      onChange: (value) {
        this.color = _tween?.transform(value);
      },
      onFinish: () {
        this.color = color;
      },
      curve: curve,
    );
  }

  @override
  void fadeIn(
    Color color, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    this.color = color.withValues(alpha: 0);
    animateToColor(color, duration: duration, curve: curve);
  }

  @override
  void fadeOut({
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    final current = color;
    if (current == null) {
      return;
    }
    animateToColor(
      current.withValues(alpha: 0),
      duration: duration,
      curve: curve,
    );
  }

  bool _containsColor() {
    return color != null && color!.a > 0;
  }

  /// Resolves a light into the world space shape that will be drawn, together
  /// with the clip path produced by its shadows (when enabled).
  ///
  /// Returns `null` when the light has no reach or when its center is inside an
  /// occluder.
  _PendingLight? _resolveLight({
    required LightingConfig config,
    required Vector2 center,
    required double angle,
    required List<LightingOccluder> occluders,
  }) {
    final radius = config.radiusWithEffects;
    if (radius <= 0) {
      return null;
    }

    final shapeRadius = _shapeRadius(config, radius);
    final shape = _buildShapePath(config, center, angle, radius);

    Path? clip;
    if (config.castShadows && occluders.isNotEmpty) {
      final polygon = computeVisibilityPolygon(
        center: center,
        radius: shapeRadius,
        occluders: occluders,
        rays: _quality.shadowRays,
      );
      if (polygon.isEmpty) {
        // Fully blocked by an occluder.
        return null;
      }
      clip = Path()
        ..addPolygon(
          polygon.map((point) => point.toOffset()).toList(growable: false),
          true,
        );
    }

    return _PendingLight(
      config: config,
      center: center,
      shape: shape,
      gradientArea: Rect.fromCircle(
        center: center.toOffset(),
        radius: shapeRadius,
      ),
      clip: clip,
    );
  }

  /// Reach of the light shape, in world units.
  double _shapeRadius(LightingConfig config, double radius) {
    final type = config.type;

    if (type is RectLightingType) {
      final scale = config.radius > 0 ? radius / config.radius : 1.0;
      final halfWidth = type.size.x / 2;
      final halfHeight = type.size.y / 2;
      return math.sqrt(halfWidth * halfWidth + halfHeight * halfHeight) * scale;
    }

    if (type is PolygonLightingType) {
      final scale = config.radius > 0 ? radius / config.radius : 1.0;
      var maxLength = 0.0;
      for (final point in type.points) {
        maxLength = math.max(maxLength, point.length);
      }
      return maxLength * scale;
    }

    return radius;
  }

  Path _buildShapePath(
    LightingConfig config,
    Vector2 center,
    double angle,
    double radius,
  ) {
    final type = config.type;

    if (type is ArcLightingType) {
      return Path()
        ..moveTo(center.x, center.y)
        ..arcTo(
          Rect.fromCircle(center: center.toOffset(), radius: radius),
          // Rotating the arc is the same as offsetting its start angle.
          type.startRadAngle + angle,
          type.endRadAngle,
          false,
        )
        ..close();
    }

    if (type is RectLightingType || type is PolygonLightingType) {
      final scale = config.radius > 0 ? radius / config.radius : 1.0;
      final List<Offset> points;

      if (type is RectLightingType) {
        final halfWidth = type.size.x * scale / 2;
        final halfHeight = type.size.y * scale / 2;
        points = [
          _rotate(Offset(-halfWidth, -halfHeight), angle),
          _rotate(Offset(halfWidth, -halfHeight), angle),
          _rotate(Offset(halfWidth, halfHeight), angle),
          _rotate(Offset(-halfWidth, halfHeight), angle),
        ];
      } else {
        points = [
          for (final point in (type as PolygonLightingType).points)
            _rotate(Offset(point.x * scale, point.y * scale), angle),
        ];
      }

      return Path()
        ..addPolygon(
          [
            for (final point in points)
              Offset(point.dx + center.x, point.dy + center.y),
          ],
          true,
        );
    }

    return Path()
      ..addOval(
        Rect.fromCircle(center: center.toOffset(), radius: radius),
      );
  }

  Offset _rotate(Offset point, double angle) {
    if (angle == 0) {
      return point;
    }
    final cos = math.cos(angle);
    final sin = math.sin(angle);
    return Offset(
      point.dx * cos - point.dy * sin,
      point.dx * sin + point.dy * cos,
    );
  }

  void _renderLight(
    Canvas canvas,
    _PendingLight light, {
    required bool cutout,
  }) {
    final clip = light.clip;
    if (clip != null) {
      canvas.save();
      canvas.clipPath(clip);
    }

    if (cutout) {
      canvas.drawPath(
        light.shape,
        _buildPaint(
          light.config,
          light.gradientArea,
          cutout: true,
          erase: true,
        ),
      );
    }

    canvas.drawPath(
      light.shape,
      _buildPaint(light.config, light.gradientArea, cutout: cutout),
    );

    if (clip != null) {
      canvas.restore();
    }
  }

  /// Builds the paint for a light.
  ///
  /// When [erase] is true the paint cuts the ambient darkness instead of
  /// tinting it. With a gradient [LightFalloff] the cut is proportional to the
  /// gradient alpha (`BlendMode.dstOut`), which produces a soft edge without
  /// the cost of `MaskFilter.blur`.
  Paint _buildPaint(
    LightingConfig config,
    Rect area, {
    required bool cutout,
    bool erase = false,
  }) {
    final paint = _paintLighting;
    final color = erase ? const Color(0xFFFFFFFF) : config.effectiveColor;
    final blendMode = erase
        ? null
        : cutout
            ? BlendMode.srcOver
            : config.additiveBlendMode;

    if (config.falloff == LightFalloff.blur) {
      paint
        ..shader = null
        ..color = color
        ..maskFilter = config.maskFilter
        ..blendMode = erase ? BlendMode.clear : blendMode!;
    } else {
      paint
        ..shader = _falloffShader(config, area, color)
        ..maskFilter = null
        ..blendMode = erase ? BlendMode.dstOut : blendMode!;
    }
    return paint;
  }

  ui.Shader _falloffShader(LightingConfig config, Rect area, Color color) {
    final inner = config.innerRadius.clamp(0.0, 1.0);

    // No falloff: the whole shape has full intensity.
    if (inner >= 1) {
      return ui.Gradient.radial(
        area.center,
        area.width / 2,
        [color, color],
        [0, 1],
      );
    }

    final transparent = color.withValues(alpha: 0);
    final colors = <Color>[];
    final stops = <double>[];

    if (inner > 0) {
      colors
        ..add(color)
        ..add(color);
      stops
        ..add(0)
        ..add(inner);
    } else {
      colors.add(color);
      stops.add(0);
    }

    if (config.falloff == LightFalloff.linear) {
      colors.add(transparent);
      stops.add(1);
    } else {
      const samples = 6;
      for (var i = 1; i <= samples; i++) {
        final t = i / samples;
        // 1 - smoothstep(t)
        final alpha = 1 - (t * t * (3 - 2 * t));
        colors.add(color.withValues(alpha: color.a * alpha));
        stops.add(inner + (1 - inner) * t);
      }
    }

    return ui.Gradient.radial(area.center, area.width / 2, colors, stops);
  }

  void _renderDebug(
    Canvas canvas,
    List<_PendingLight> lights,
    List<LightingOccluder> occluders,
  ) {
    final zoom = gameRef.camera.zoom;
    final strokeWidth = 1.5 / zoom;

    final shapePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFF00E676);
    final occluderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFFF1744);
    final clipPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = const Color(0xFFFFFF00);
    final centerPaint = Paint()..color = const Color(0xFF00E676);

    canvas.save();
    _applyCameraTransform(canvas);

    for (final occluder in occluders) {
      canvas.drawPath(_polygonPath(occluder.points), occluderPaint);
    }

    for (final light in lights) {
      canvas.drawPath(light.shape, shapePaint);
      final clip = light.clip;
      if (clip != null) {
        canvas.drawPath(clip, clipPaint);
      }
      canvas.drawCircle(light.center.toOffset(), 2 / zoom, centerPaint);
    }

    canvas.restore();
  }

  Path _polygonPath(List<Vector2> points) {
    final path = Path();
    if (points.isEmpty) {
      return path;
    }
    path.moveTo(points.first.x, points.first.y);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }
    return path..close();
  }

  @override
  void onGameResize(Vector2 size) {
    bounds = gameRef.camera.viewport.virtualSize.toRect();
    super.onGameResize(size);
  }
}

/// A light resolved to world coordinates, ready to be rendered.
class _PendingLight {
  final LightingConfig config;
  final Vector2 center;
  final Path shape;
  final Rect gradientArea;
  final Path? clip;

  const _PendingLight({
    required this.config,
    required this.center,
    required this.shape,
    required this.gradientArea,
    required this.clip,
  });
}
