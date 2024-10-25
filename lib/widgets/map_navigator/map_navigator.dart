import 'package:bonfire/widgets/map_navigator/map_navigator_controller.dart';
import 'package:flutter/widgets.dart';

import 'map_navigator_provider.dart';

class MapNavigator extends StatefulWidget {
  final Map<String, MapItem> maps;
  final String? initialMap;
  final Widget Function(BuildContext context, MapItem map) builder;
  MapNavigator({
    super.key,
    required this.maps,
    this.initialMap,
    required this.builder,
  }) : assert(maps.isNotEmpty);

  static MapNavigatorController of(BuildContext context) {
    return MapNavigatorProvider.of(context).controller;
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
          return widget.builder(context, controller.current);
        },
      ),
    );
  }
}
