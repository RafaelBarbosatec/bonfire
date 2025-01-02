import 'package:bonfire/bonfire.dart';

extension PositionComponentExt on PositionComponent {
  double get left => position.x * size.x;
  double get right => (position.x * size.x) + size.x;
  double get top => position.y * size.y;
  double get bottom => (position.y * size.y) + size.y;
}
