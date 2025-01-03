import 'dart:ui';

extension ColorExtensions on Color {
  Color setOpacity(double opacity) {
    return withOpacity(opacity);
  }
}
