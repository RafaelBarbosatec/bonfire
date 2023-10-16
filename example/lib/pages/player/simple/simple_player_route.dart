import 'package:example/pages/player/simple/simple_player_page.dart';
import 'package:flutter/widgets.dart';

class SimplePlayerRoute {
  static const String routeName = '/simple-player';

  static Map<String, WidgetBuilder> get builder {
    return {
      routeName: (context) => const SimplePlayerPage(),
    };
  }

  static Future open(BuildContext context) {
    return Navigator.pushNamed(context, routeName);
  }
}
