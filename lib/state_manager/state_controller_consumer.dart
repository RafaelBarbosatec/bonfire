import 'package:bonfire/bonfire.dart';
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

typedef StateControllerWidgetBuilder<T> = Widget Function(
    BuildContext context, T controller);

class StateControllerConsumer<T extends StateController>
    extends StatefulWidget {
  final T? controller;
  final StateControllerWidgetBuilder<T> builder;
  const StateControllerConsumer({
    Key? key,
    required this.builder,
    this.controller,
  }) : super(key: key);

  @override
  StateControllerConsumerState<T> createState() =>
      StateControllerConsumerState<T>();
}

class StateControllerConsumerState<T extends StateController>
    extends State<StateControllerConsumer> {
  late T controller;
  @override
  void initState() {
    controller = myWidget.controller ?? BonfireInjector().get<T>();
    controller.addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return myWidget.builder(context, controller);
  }

  StateControllerConsumer<T> get myWidget {
    return widget as StateControllerConsumer<T>;
  }

  void _listener() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        setState(() {});
      }
    });
  }
}
