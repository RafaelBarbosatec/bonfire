import 'package:example/pages/enemy/enemy_route.dart';
import 'package:example/pages/forces/forces_route.dart';
import 'package:example/pages/home/home_route.dart';
import 'package:example/pages/lighting/lighting_route.dart';
import 'package:example/pages/path_finding/path_finding_route.dart';
import 'package:example/pages/player/platform/platform_player_route.dart';
import 'package:example/pages/player/simple/simple_player_route.dart';
import 'package:flutter/widgets.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
        ...HomeRoute.builder,
        ...ForcesRoute.builder,
        ...EnemyRoute.builder,
        ...PathFindingRoute.builder,
        ...LightingRoute.builder,
        ...SimplePlayerRoute.builder,
        ...PlatformPlayerRoute.builder,
      };
}
