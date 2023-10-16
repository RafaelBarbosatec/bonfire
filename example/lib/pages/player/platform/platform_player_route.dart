import 'package:example/pages/player/platform/platform_player_page.dart';
import 'package:flutter/widgets.dart';

class PlatformPlayerRoute {
  static const String routeName = '/platform-player';

  static Map<String, WidgetBuilder> get builder {
    return {
      routeName: (context) => const PlatformPlayerPage(),
    };
  }

  static Future open(BuildContext context) {
    return Navigator.pushNamed(context, routeName);
  }
}
