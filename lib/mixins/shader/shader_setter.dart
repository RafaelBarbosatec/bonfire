import 'dart:ui';

import 'package:bonfire/bonfire.dart';

abstract class ShaderSetterItem {}

class SetterDouble implements ShaderSetterItem {
  final double value;

  SetterDouble(this.value);
}

class SetterImage implements ShaderSetterItem {
  final Image value;

  SetterImage(this.value);
}

class SetterVector2 implements ShaderSetterItem {
  final Vector2 value;

  SetterVector2(this.value);
}

class SetterColor implements ShaderSetterItem {
  final Color value;

  SetterColor(this.value);
}

class ShaderSetter {
  final List<ShaderSetterItem> values;
  final int startFloatIndex;
  final int startImageIndex;
  int _indexFloat = 0;
  int _indexImage = 0;
  ShaderSetter({
    required this.values,
    this.startFloatIndex = 3,
    this.startImageIndex = 1,
  });

  void apply(FragmentShader shader) {
    _indexFloat = startFloatIndex;
    _indexImage = startImageIndex;
    for (final item in values) {
      if (item is SetterDouble) {
        _setFloat(shader, item.value);
      }
      if (item is SetterImage) {
        _setSampler(shader, item.value);
      }

      if (item is SetterVector2) {
        _setFloat(shader, item.value.x);
        _setFloat(shader, item.value.y);
      }

      if (item is SetterColor) {
        final color = item.value;
        _setFloat(shader, color.red / 255 * color.opacity);
        _setFloat(shader, color.green / 255 * color.opacity);
        _setFloat(shader, color.blue / 255 * color.opacity);
        _setFloat(shader, color.opacity);
      }
    }
  }

  void _setFloat(FragmentShader shader, double value) {
    shader.setFloat(_indexFloat, value);
    _indexFloat++;
  }

  void _setSampler(FragmentShader shader, Image value) {
    shader.setImageSampler(_indexImage, value);
    _indexImage++;
  }
}
