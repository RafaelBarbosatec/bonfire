import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

// Mixin used to adds a BarLife to the attacable component
mixin UseLifeBar on WithLife {
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

  void setupLifeBar({
    Vector2? size,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 2,
    List<Color>? colors,
    BorderRadius? borderRadius,
    BarLifeDrawPosition barLifeDrawPosition = BarLifeDrawPosition.top,
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
    _barLifeDrawPosition = barLifeDrawPosition;
    _barOffset = offset;
    _textStyle = textStyle;
    _showLifeText = showLifeText;
    _barLifetextBuilder = barLifetextBuilder;
    _size = size;
  }

  @override
  void onMount() {
    add(
      barLife = BarLifeComponent(
        target: this,
        size: _size,
        offset: _barOffset,
        backgroundColor: _backgroundColor,
        borderColor: _borderColor,
        borderWidth: _borderWidth,
        colors: _colors,
        life: life.value,
        maxLife: life.max,
        borderRadius: _borderRadius,
        drawPosition: _barLifeDrawPosition,
        textStyle: _textStyle,
        showLifeText: _showLifeText,
        barLifeTextBuilder: _barLifetextBuilder,
        padding: _padding,
      ),
    );
    life.onInitialLifeListener((double value) {
      barLife?.updateLife(value);
      barLife?.updatemaxLife(value);
    });
    life.onRemoveLifeListener((double _) => _animateBar());
    life.onRestoreLifeListener((double _) => _animateBar());
    life.onLifeUpdateListener((double value) => barLife?.updateLife(value));
    super.onMount();
  }

  @override
  void onRemove() {
    barLife?.removeFromParent();
    super.onRemove();
  }

  void _animateBar() {
    if (hasGameRef) {
      _valueGenerator?.reset();
      _valueGenerator?.removeFromParent();
      _valueGenerator = generateValues(
        const Duration(milliseconds: 300),
        begin: barLife?.life ?? 0,
        end: life.value,
        onChange: (value) {
          barLife?.updateLife(value);
        },
      )..start();
    }
  }
}
