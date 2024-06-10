import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';

class GestureEvent {
  final int pointer;
  final Vector2 screenPosition;
  final Vector2 worldPosition;
  final PointerDeviceKind kind;

  GestureEvent({
    required this.pointer,
    required this.screenPosition,
    required this.worldPosition,
    required this.kind,
  });

  factory GestureEvent.fromPointerEvent(
    PointerEvent event, {
    required Vector2 Function(Vector2 position) screenToWorld,
    required Vector2 Function(Vector2 position) globalToViewportPosition,
  }) {
    final eventPosition = event.localPosition.toVector2();
    final screenPosition = globalToViewportPosition(eventPosition);
    return GestureEvent(
      pointer: event.pointer,
      kind: event.kind,
      screenPosition: screenPosition,
      worldPosition: screenToWorld(eventPosition),
    );
  }
}
