import 'package:bonfire/widgets/map_navigator/map_navigator_controller.dart';
import 'package:flutter/material.dart';

class MapNavigatorProvider extends InheritedWidget {
  final MapNavigatorController controller;
  const MapNavigatorProvider({
    super.key,
    required this.controller,
    required super.child,
  });

  static MapNavigatorProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MapNavigatorProvider>();
  }

  static MapNavigatorProvider of(BuildContext context) {
    final MapNavigatorProvider? result = maybeOf(context);
    assert(result != null, 'No FrogColor found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MapNavigatorProvider oldWidget) =>
      controller != oldWidget.controller;
}
