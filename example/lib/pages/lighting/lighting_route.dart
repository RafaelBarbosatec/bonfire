import 'package:example/pages/lighting/lighting_page.dart';
import 'package:flutter/widgets.dart';

class LightingRoute {
  static const String routeName = '/lighting';

  static Map<String, WidgetBuilder> get builder {
    return {
      routeName: (context) => const LightingPage(),
    };
  }

  static Future open(BuildContext context) {
    return Navigator.pushNamed(context, routeName);
  }
}
