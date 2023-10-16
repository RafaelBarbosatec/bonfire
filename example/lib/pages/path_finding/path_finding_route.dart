import 'package:example/pages/path_finding/path_finding_page.dart';
import 'package:flutter/widgets.dart';

class PathFindingRoute {
  static const String routeName = '/path-finding';

  static Map<String, WidgetBuilder> get builder {
    return {
      routeName: (context) => const PathFindingPage(),
    };
  }

  static Future open(BuildContext context) {
    return Navigator.pushNamed(context, routeName);
  }
}
