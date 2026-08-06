import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

/// Mixin used to adds a BarLife to the attackable component.
class LifeBarApi {
  final WithLife comp;

  BarLifeComponent? barLife;

  Color _backgroundColor = const Color(0xFF000000);
  Color _borderColor = const Color(0xFFFFFFFF);
  double _borderWidth = 2;
  List<Color>? _colors;
  Vector2? _barOffset;
  BorderRadius _borderRadius = BorderRadius.zero;
  BarLifeDrawPosition _barLifeDrawPosition = BarLifeDrawPosition.bottom;
  TextStyle? _textStyle;
  bool _showLifeText = true;
  ValueGeneratorComponent? _valueGenerator;
  BarLifeTextBuilder? _barLifetextBuilder;
  EdgeInsets? _padding;
  Vector2? _size;

  LifeBarApi(this.comp);

  /// Sets up the life bar appearance and behavior.
  void setup({
    Vector2? size,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 2,
    List<Color>? colors,
    BorderRadius? borderRadius,
    BarLifeDrawPosition drawPosition = BarLifeDrawPosition.top,
    Vector2? offset,
    Vector2? textOffset,
    TextStyle? textStyle,
    bool showLifeText = true,
    BarLifeTextBuilder? barLifetextBuilder,
    EdgeInsets? padding,
  }) {
    _padding = padding;
    _backgroundColor = backgroundColor ?? _backgroundColor;
    _borderColor = borderColor ?? _borderColor;
    _borderWidth = borderWidth;
    _colors = colors;
    _borderRadius = borderRadius ?? _borderRadius;
    _barLifeDrawPosition = drawPosition;
    _barOffset = offset;
    _textStyle = textStyle;
    _showLifeText = showLifeText;
    _barLifetextBuilder = barLifetextBuilder;
    _size = size;
  }

  /// Mounts the life bar component and listeners.
  void mount() {
    comp.add(
      barLife = BarLifeComponent(
        target: comp as GameComponent,
        size: _size,
        offset: _barOffset,
        backgroundColor: _backgroundColor,
        borderColor: _borderColor,
        borderWidth: _borderWidth,
        colors: _colors,
        life: comp.life.value,
        maxLife: comp.life.max,
        borderRadius: _borderRadius,
        drawPosition: _barLifeDrawPosition,
        textStyle: _textStyle,
        showLifeText: _showLifeText,
        barLifeTextBuilder: _barLifetextBuilder,
        padding: _padding,
      ),
    );
    comp.life.onInitialLifeListener((double value) {
      barLife?.updateLife(value);
      barLife?.updatemaxLife(value);
    });
    comp.life.onRemoveLifeListener((double _) => _animateBar());
    comp.life.onRestoreLifeListener((double _) => _animateBar());
    comp.life.onLifeUpdateListener((double value) => barLife?.updateLife(value));
  }

  /// Removes the life bar from the component.
  void dispose() {
    barLife?.removeFromParent();
  }

  void _animateBar() {
    final gameComponent = comp as GameComponent;
    if (gameComponent.hasGameRef) {
      _valueGenerator?.reset();
      _valueGenerator?.removeFromParent();
      _valueGenerator = gameComponent.generateValues(
        const Duration(milliseconds: 300),
        begin: barLife?.life ?? 0,
        end: comp.life.value,
        onChange: (value) {
          barLife?.updateLife(value);
        },
      )..start();
    }
  }
}
