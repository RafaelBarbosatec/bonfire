import 'dart:ui';

class MapPaint {
  final Paint _paint = Paint()..isAntiAlias = false;
  static final MapPaint instance = MapPaint._internal();
  MapPaint._internal();
  Paint get paint => _paint;
}
