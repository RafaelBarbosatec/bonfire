import 'dart:math';

import 'package:flutter/widgets.dart';

double getZoomFromMaxVisibleTile(
  BuildContext context,
  double tileSize,
  int maxTile,
) {
  final screenSize = MediaQuery.of(context).size;
  final maxSize = max(screenSize.width, screenSize.height);
  return maxSize / (tileSize * maxTile);
}
