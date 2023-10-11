import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/bonfire_camera.dart';
import 'package:flutter/widgets.dart';

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
/// on 28/09/21

final Map<String, OverlayEntry> _mapOverlayEntry = {};

/// With this widget you can add a widget what follows a component in the game.
class FollowerWidget extends StatefulWidget {
  final GameComponent target;
  final Widget child;
  final Offset align;
  const FollowerWidget({
    Key? key,
    required this.target,
    required this.child,
    this.align = Offset.zero,
  }) : super(key: key);

  /// Use this method to show a widget what follow the component
  static void show({
    required String identify,
    required BuildContext context,
    required GameComponent target,
    required Widget child,
    Offset align = Offset.zero,
  }) {
    final overlay = OverlayEntry(
      builder: (context) {
        return FollowerWidget(
          target: target,
          align: align,
          child: child,
        );
      },
    );
    // ignore: invalid_null_aware_operator
    Overlay.of(context)?.let((over) {
      over.insert(overlay);
      _mapOverlayEntry[identify] = overlay;
    });
  }

  /// Use this method to remove a widget what follow the component
  static remove(String identify) {
    if (_mapOverlayEntry.containsKey(identify)) {
      _mapOverlayEntry[identify]?.remove();
      _mapOverlayEntry.remove(identify);
    }
  }

  /// Use this method to remove all widgets what follow the component.
  static removeAll() {
    _mapOverlayEntry.forEach((key, value) {
      value.remove();
    });
    _mapOverlayEntry.clear();
  }

  /// Use this method to check if is visible widget with your `identify`.
  static bool isVisible(String identify) {
    return _mapOverlayEntry.containsKey(identify);
  }

  @override
  FollowerWidgetState createState() => FollowerWidgetState();
}

class FollowerWidgetState extends State<FollowerWidget> {
  Vector2 targetPosition = Vector2.zero();
  Vector2? widgetPosition;
  double lastZoom = 0.0;
  Vector2 lastCameraPosition = Vector2.zero();
  late BonfireCamera camera;
  @override
  void initState() {
    widget.target.position.addListener(_positionListener);
    super.initState();
  }

  @override
  void dispose() {
    widget.target.position.removeListener(_positionListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widgetPosition != null) {
      return Positioned(
        top: widgetPosition!.y + widget.align.dy,
        left: widgetPosition!.x + widget.align.dx,
        child: widget.child,
      );
    }
    return const SizedBox.shrink();
  }

  void _positionListener() {
    camera = widget.target.gameRef.camera;
    final absolutePosition = widget.target.absolutePosition;
    if (targetPosition != absolutePosition ||
        camera.zoom != lastZoom ||
        camera.position != lastCameraPosition) {
      lastZoom = camera.zoom;
      targetPosition = absolutePosition.clone();
      lastCameraPosition = camera.position.clone();
      if (mounted) {
        setState(() {
          widgetPosition = widget.target.gameRef.worldToScreen(
            targetPosition,
          );
        });
      }
    }
  }
}
