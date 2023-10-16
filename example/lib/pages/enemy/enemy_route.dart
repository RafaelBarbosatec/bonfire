import 'package:example/pages/enemy/enemy_page.dart';
import 'package:flutter/widgets.dart';

class EnemyRoute {
  static const String routeName = '/enemy';

  static Map<String, WidgetBuilder> get builder {
    return {
      routeName: (context) => const EnemyPage(),
    };
  }

  static Future open(BuildContext context) {
    return Navigator.pushNamed(context, routeName);
  }
}
