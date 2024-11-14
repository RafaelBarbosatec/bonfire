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

  ShaderSetter({
    required this.values,
    this.startFloatIndex = 3,
    this.startImageIndex = 1,
  });

  void apply(FragmentShader shader) {
    int indexFloat = startFloatIndex;
    int indexImage = startImageIndex;
    for (var item in values) {
      if (item is SetterDouble) {
        shader.setFloat(indexFloat, item.value);
        indexFloat++;
      }
      if (item is SetterImage) {
        shader.setImageSampler(indexImage, item.value);
        indexImage++;
      }

      if (item is SetterVector2) {
        shader.setFloat(indexFloat, item.value.x);
        indexFloat++;
        shader.setFloat(indexFloat, item.value.y);
        indexFloat++;
      }

      if (item is SetterColor) {
        final color = item.value;
        shader.setFloat(indexFloat, color.red / 255 * color.opacity);
        indexFloat++;
        shader.setFloat(indexFloat, color.green / 255 * color.opacity);
        indexFloat++;
        shader.setFloat(indexFloat, color.blue / 255 * color.opacity);
        indexFloat++;
        shader.setFloat(indexFloat, color.opacity);
        indexFloat++;
      }
    }
  }
}
