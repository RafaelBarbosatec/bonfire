import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/empty_map.dart';
import 'package:example/pages/simple_test/simple_p_m.dart';
import 'package:flutter/material.dart';

class SimpleGameTest extends StatelessWidget {
  const SimpleGameTest({super.key});

  @override
  Widget build(BuildContext context) {
    final p = SimplePM();
    return BonfireWidget(
      map: EmptyWorldMap(),
      components: [p, SimpleCollitionT()],
      debugMode: true,
      playerControllers: [
        Keyboard(
          observer: p,
        )
      ],
    );
  }
}
