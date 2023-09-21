import 'package:example/pages/home/home_page.dart';
import 'package:flutter/widgets.dart';

class HomeRoute {
  static const String routeName = '/';

  static Map<String, WidgetBuilder> get builder {
    return {
      routeName: (context) => const HomePage(),
    };
  }

  static Future open(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(context, routeName, (_) => false);
  }
}
