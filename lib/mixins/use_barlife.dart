import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

mixin UseBarLife on Attackable {
  BarLifeComponent? barLife;
  Vector2? _barLifeSize;
  Color _backgroundColor = const Color(0xFF000000);
  Color _borderColor = const Color(0xFFFFFFFF);
  double _borderWidth = 2;
  double _margin = 4;
  List<Color>? _colors;
  Vector2? _offset;
  Vector2? _textOffset;
  BorderRadius _borderRadius = BorderRadius.zero;
  BarLifePorition _barLifePosition = BarLifePorition.bottom;
  TextStyle? _textStyle;
  bool _showLifeText = true;
  ValueGeneratorComponent? _valueGenerator;
  BarLifeTextBuilder? _barLifetextBuilder;

  void setupBarLife({
    Vector2? size,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 2,
    double margin = 4,
    List<Color>? colors,
    BorderRadius? borderRadius,
    BarLifePorition barLifePosition = BarLifePorition.top,
    Vector2? offset,
    Vector2? textOffset,
    TextStyle? textStyle,
    bool showLifeText = true,
    BarLifeTextBuilder? barLifetextBuilder,
  }) {
    _barLifeSize = size;
    _backgroundColor = backgroundColor ?? _backgroundColor;
    _borderColor = borderColor ?? _borderColor;
    _borderWidth = borderWidth;
    _colors = colors;
    _borderRadius = borderRadius ?? _borderRadius;
    _barLifePosition = barLifePosition;
    _margin = margin;
    _offset = offset;
    _textStyle = textStyle;
    _showLifeText = showLifeText;
    _textOffset = textOffset;
    _barLifetextBuilder = barLifetextBuilder;
  }

  @override
  void onMount() {
    gameRef.add(
      barLife = BarLifeComponent(
        target: this,
        size: _barLifeSize ?? Vector2(width, 6),
        backgroundColor: _backgroundColor,
        borderColor: _borderColor,
        borderWidth: _borderWidth,
        colors: _colors,
        life: life,
        maxLife: maxLife,
        borderRadius: _borderRadius,
        drawPosition: _barLifePosition,
        margin: _margin,
        offset: _offset,
        textStyle: _textStyle,
        showLifeText: _showLifeText,
        textOffset: _textOffset,
        barLifetextBuilder: _barLifetextBuilder,
      ),
    );
    super.onMount();
  }

  @override
  void initialLife(double life) {
    barLife?.updateLife(life);
    barLife?.updatemaxLife(life);
    super.initialLife(life);
  }

  @override
  void addLife(double life) {
    super.addLife(life);
    _animateBar();
  }

  @override
  void removeLife(double life) {
    super.removeLife(life);
    _animateBar();
  }

  @override
  void updateLife(double life, {bool verifyDieOrRevive = true}) {
    super.updateLife(life, verifyDieOrRevive: verifyDieOrRevive);
    barLife?.updateLife(super.life);
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
        end: life,
        onChange: (value) {
          barLife?.updateLife(value);
        },
      )..start();
    }
  }
}
