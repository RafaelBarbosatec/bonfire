import 'package:example/pages/forces/forces_page.dart';
import 'package:flutter/widgets.dart';

class ForcesRoute {
  static const String routeName = '/forces';

  static Map<String, WidgetBuilder> get builder {
    return {
      routeName: (context) => const ForcesPage(),
    };
  }

  static Future open(BuildContext context) {
    return Navigator.pushNamed(context, routeName);
  }
}
