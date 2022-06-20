import 'package:bonfire/bonfire.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 20/06/22

class BonfireOpacityEffect extends Effect {
  final double targetOpacity;
  double _diffOpacity = 0;
  double _initialOpacity = 0;
  BonfireOpacityEffect(
    this.targetOpacity,
    EffectController controller, {
    Function()? onComplete,
  }) : super(
          controller,
          onComplete: onComplete,
        );

  BonfireOpacityEffect.fadeOut(
    EffectController controller, {
    Function()? onComplete,
  })  : targetOpacity = 0.0,
        super(
          controller,
          onComplete: onComplete,
        );

  BonfireOpacityEffect.fadeIn(
    EffectController controller, {
    Function()? onComplete,
  })  : targetOpacity = 1.0,
        super(
          controller,
          onComplete: onComplete,
        );
  @override
  void apply(double progress) {
    if (parent is GameComponent) {
      double newOpacity = _initialOpacity + (_diffOpacity * progress);
      if (newOpacity > 1.0) {
        newOpacity = 1.0;
      }

      if (newOpacity < 0.0) {
        newOpacity = 0.0;
      }
      (parent as GameComponent).opacity = newOpacity;
    }
  }

  @override
  void onStart() {
    if (parent is GameComponent) {
      _initialOpacity = (parent as GameComponent).opacity;
      _diffOpacity = targetOpacity - _initialOpacity;
    }
  }
}
