import 'package:bonfire/widgets/map_navigator/map_navigator_controller.dart';
import 'package:flutter/material.dart';

import 'map_navigator_provider.dart';

export 'package:bonfire/widgets/map_navigator/map_navigator_controller.dart';

typedef BonfireMapBuilder = Widget Function(
  BuildContext context,
  Object? arguments,
  MapItem map,
);

typedef MapItemBuilder = MapItem Function(Object? arguments);

class MapNavigator extends StatefulWidget {
  final Map<String, MapItemBuilder> maps;
  final String? initialMap;
  final BonfireMapBuilder builder;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final AnimatedSwitcherLayoutBuilder? layoutBuilder;
  final Duration transitionDuration;
  final Curve transitionCurve;

  MapNavigator({
    super.key,
    required this.maps,
    this.initialMap,
    required this.builder,
    this.transitionBuilder,
    this.layoutBuilder,
    this.transitionDuration = Durations.medium2,
    this.transitionCurve = Curves.linear,
  }) : assert(maps.isNotEmpty);

  static MapNavigatorController of(BuildContext context) {
    return MapNavigatorProvider.of(context).controller;
  }

  static Widget defaultLayoutBuilder(
    Widget? currentChild,
    List<Widget> previousChildren,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        if (currentChild != null) currentChild,
      ],
    );
  }

  @override
  State<MapNavigator> createState() => _MapNavigatorState();
}

class _MapNavigatorState extends State<MapNavigator> {
  late MapNavigatorController controller;
  @override
  void initState() {
    controller = MapNavigatorController(
      maps: widget.maps,
      initialMap: widget.initialMap,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MapNavigatorProvider(
      controller: controller,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, child) {
          final current = controller.current;
          return AnimatedSwitcher(
            duration: widget.transitionDuration,
            layoutBuilder:
                widget.layoutBuilder ?? MapNavigator.defaultLayoutBuilder,
            transitionBuilder: widget.transitionBuilder ??
                AnimatedSwitcher.defaultTransitionBuilder,
            switchInCurve: widget.transitionCurve,
            child: Container(
              key: Key(current.id),
              child: widget.builder(
                context,
                controller.arguments,
                current,
              ),
            ),
          );
        },
      ),
    );
  }
}
