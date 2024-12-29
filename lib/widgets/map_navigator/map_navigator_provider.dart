import 'package:bonfire/widgets/map_navigator/map_navigator_controller.dart';
import 'package:flutter/material.dart';

class MapNavigatorProvider extends InheritedWidget {
  final MapNavigatorController controller;
  const MapNavigatorProvider({
    required this.controller,
    required super.child,
    super.key,
  });

  static MapNavigatorProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MapNavigatorProvider>();
  }

  static MapNavigatorProvider of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No FrogColor found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(MapNavigatorProvider oldWidget) =>
      controller != oldWidget.controller;
}
