import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:flutter/gestures.dart';

class FingerPoint {
  final int id;
  final Vector2 position;
  late Vector2 _initialPosition;
  Vector2 get initialPosition => _initialPosition;
  FingerPoint({
    required this.id,
    required this.position,
  }) {
    _initialPosition = position.clone();
  }
}

mixin PinchGesture on GameComponent {
  final List<FingerPoint> _fingers = [];
  bool _startPinch = false;

  @override
  bool handlerPointerDown(PointerDownEvent event) {
    final gEvent = GestureEvent.fromPointerEvent(
      event,
      screenToWorld: gameRef.screenToWorld,
      globalToViewportPosition: gameRef.globalToViewportPosition,
    );
    if (!_fingers.any((element) => element.id == gEvent.pointer)) {
      _fingers.add(
        FingerPoint(
          id: gEvent.pointer,
          position: gEvent.screenPosition,
        ),
      );
    }
    return super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    _fingers.removeWhere((element) => element.id == event.pointer);
    if (_startPinch) {
      _startPinch = false;
      onPinchEnd();
    }
    return super.handlerPointerUp(event);
  }

  @override
  bool handlerPointerCancel(PointerCancelEvent event) {
    _fingers.removeWhere((element) => element.id == event.pointer);
    if (_startPinch) {
      _startPinch = false;
      onPinchEnd();
    }
    return super.handlerPointerCancel(event);
  }

  @override
  bool handlerPointerMove(PointerMoveEvent event) {
    final gEvent = GestureEvent.fromPointerEvent(
      event,
      screenToWorld: gameRef.screenToWorld,
      globalToViewportPosition: gameRef.globalToViewportPosition,
    );
    _updateFingers(gEvent);
    _handleMove();
    return super.handlerPointerMove(event);
  }

  @override
  bool get isVisible => true;

  void _updateFingers(GestureEvent event) {
    for (final finger in _fingers) {
      if (finger.id == event.pointer) {
        finger.position.setFrom(event.screenPosition);
      }
    }
  }

  void _handleMove() {
    if (_fingers.length == 2) {
      final finger1 = _fingers[0];
      final finger2 = _fingers[1];
      final event = PinchEvent.fromFingers(finger1, finger2);

      if (!_startPinch) {
        _startPinch = true;
        onPinchStart(event);
      }
      onPinchUpdate(event);
    }
  }

  void onPinchUpdate(PinchEvent event) {}
  void onPinchStart(PinchEvent event) {}
  void onPinchEnd() {}

  @override
  bool hasGesture() => true;
}

class PinchEvent {
  final double initalDistance;
  final double initalAngle;
  final Vector2 initalCenter;
  final double distance;
  final double angle;
  final Vector2 center;
  final FingerPoint finger1;
  final FingerPoint finger2;

  PinchEvent({
    required this.initalDistance,
    required this.initalAngle,
    required this.initalCenter,
    required this.distance,
    required this.angle,
    required this.center,
    required this.finger1,
    required this.finger2,
  });

  factory PinchEvent.fromFingers(FingerPoint f1, FingerPoint f2) {
    final initialPosition = Vector2(
      min(f1.initialPosition.x, f2.initialPosition.x),
      min(f1.initialPosition.y, f2.initialPosition.y),
    );
    final position = Vector2(
      min(f1.position.x, f2.position.x),
      min(f1.position.y, f2.position.y),
    );
    return PinchEvent(
      initalAngle: f1.initialPosition.angleTo(f2.initialPosition),
      initalCenter: initialPosition,
      initalDistance: f1.initialPosition.distanceTo(f2.initialPosition),
      angle: f1.position.angleTo(f2.position),
      center: position,
      distance: f1.position.distanceTo(f2.position),
      finger1: f1,
      finger2: f2,
    );
  }

  Vector2 get diffCenter => center - initalCenter;
  double get diffAngle => angle - initalAngle;
  double get diffDistance => distance - initalDistance;

  double get factorAngle => angle / initalAngle;
  double get factorDistance => distance / initalDistance;
}
