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
  _StateControllerConsumerState<T> createState() =>
      _StateControllerConsumerState<T>();
}

class _StateControllerConsumerState<T extends StateController>
    extends State<StateControllerConsumer> {
  late T controller;
  @override
  void initState() {
    controller = (widget as StateControllerConsumer<T>).controller ?? get<T>();
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
    return (widget as StateControllerConsumer<T>).builder(context, controller);
  }

  void _listener() {
    Future.delayed(Duration.zero, () {
      setState(() {});
    });
  }
}
