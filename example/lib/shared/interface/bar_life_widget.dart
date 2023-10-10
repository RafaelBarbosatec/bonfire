import 'package:example/shared/interface/bar_life_controller.dart';
import 'package:flutter/material.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 04/03/22
class BarLifeWidget extends StatelessWidget {
  const BarLifeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = BarLifeController();
    return Material(
      type: MaterialType.transparency,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          return Padding(
            padding: const EdgeInsets.only(left: 45, top: 60),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      controller.life.toString(),
                      style: const TextStyle(color: Colors.green),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(color: Colors.green),
                    ),
                    Text(
                      controller.maxLife.toString(),
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      controller.stamina.toString(),
                      style: const TextStyle(color: Colors.yellowAccent),
                    ),
                    const Text(
                      ' / ',
                      style: TextStyle(color: Colors.yellowAccent),
                    ),
                    Text(
                      controller.maxStamina.toString(),
                      style: const TextStyle(color: Colors.yellowAccent),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
