import 'package:bonfire/bonfire.dart';

/// API used to configure lighting in a component.
class LightingApi {
  final GameComponent _comp;

  LightingConfig? _config;

  LightingConfig? _animationTarget;
  LightingConfig? _animationStart;
  Duration _animationDuration = Duration.zero;
  Curve _animationCurve = Curves.decelerate;
  double _animationElapsed = 0;

  /// Used to define rotation angle.
  double angle = 0.0;

  /// Used to enable and disable light.
  bool enabled = true;

  LightingApi(this._comp);

  /// Current lighting configuration.
  LightingConfig? get config => _config;

  /// Whether a [animateTo] transition is currently running.
  bool get isAnimating => _animationTarget != null;

  /// Sets the lighting configuration immediately, cancelling any running
  /// transition.
  void setup(LightingConfig? config) {
    _config = config;
    _animationTarget = null;
    _animationStart = null;
  }

  /// Animates the current configuration to [config].
  ///
  /// The radius, color, blur and alignment are interpolated. Discrete fields
  /// (type, mode, pulses) switch when the animation crosses its middle point.
  /// When there is no current configuration, or [duration] is zero, the
  /// configuration is applied immediately.
  void animateTo(
    LightingConfig config, {
    Duration duration = const Duration(milliseconds: 500),
    Curve curve = Curves.decelerate,
  }) {
    final current = _config;
    if (current == null || duration <= Duration.zero) {
      setup(config);
      return;
    }

    _animationStart = current;
    _animationTarget = config;
    _animationDuration = duration;
    _animationCurve = curve;
    _animationElapsed = 0;
  }

  /// Stops a running [animateTo] transition, keeping the current state.
  void stopAnimation() {
    _animationTarget = null;
    _animationStart = null;
  }

  double _calculateAngle() {
    final config = _config;
    if (config != null && config.type is ArcLightingType) {
      final type = config.type as ArcLightingType;
      if (type.isCenter) {
        return _comp.angle - (type.endRadAngle / 2);
      } else {
        return _comp.angle - type.endRadAngle;
      }
    }
    return 0.0;
  }

  /// Updates lighting state. Should be called by the component's [update].
  void update(double dt) {
    _updateAnimation(dt);

    if (_config?.useComponentAngle == true) {
      angle = _calculateAngle();
    }
  }

  void _updateAnimation(double dt) {
    final target = _animationTarget;
    final start = _animationStart;
    if (target == null || start == null) {
      return;
    }

    _animationElapsed += dt;
    final total = _animationDuration.inMicroseconds / 1000000;
    final progress =
        total <= 0 ? 1.0 : (_animationElapsed / total).clamp(0.0, 1.0);

    if (progress >= 1) {
      _config = target;
      _animationTarget = null;
      _animationStart = null;
      return;
    }

    _config = start.lerpTo(target, _animationCurve.transform(progress));
  }
}
