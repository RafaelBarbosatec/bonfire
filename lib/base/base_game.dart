import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/bonfire.dart';
import 'package:bonfire/camera/camera.dart';
import 'package:bonfire/camera/camera_config.dart';
import 'package:bonfire/util/bonfire_game_ref.dart';
import 'package:bonfire/util/mixins/pointer_detector.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart' hide Camera;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// CustomBaseGame created to use `Listener` to capture touch screen gestures.
/// Apply zoom in canvas.
/// Reorder components per time frame.
abstract class BaseGame extends Component
    with Loadable, Game, FPSCounter, PointerDetector {
  Camera camera = Camera(CameraConfig());

  /// variable that keeps the highest rendering priority per frame. This is used to determine the order in which to render the `interface`, `lighting` and `joystick`
  int _highestPriority = 1000000;

  /// Get of the _highestPriority
  int get highestPriority => _highestPriority;

  /// to get the components that contain gestures
  Iterable<PointerDetectorHandler> get _gesturesComponents {
    return children.where((c) => _hasGesture(c)).cast<PointerDetectorHandler>();
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerCancel(event);
    }
  }

  @override
  void onPointerUp(PointerUpEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerUp(event);
    }
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerMove(event);
    }
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerDown(event);
    }
  }

  @override
  void onPointerHover(PointerHoverEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerHover(event);
    }
  }

  @override
  void onPointerSignal(PointerSignalEvent event) {
    if (!hasLayout) return;
    for (final c in _gesturesComponents) {
      c.handlerPointerSignal(event);
    }
  }

  /// This implementation of render basically calls [renderComponent] for every component, making sure the canvas is reset for each one.
  ///
  /// You can override it further to add more custom behaviour.
  /// Beware of however you are rendering components if not using this; you must be careful to save and restore the canvas to avoid components messing up with each other.
  @override
  void render(Canvas canvas) {
    if (!hasLayout) return;
    canvas.save();

    canvas.translate(size.x / 2, size.y / 2);
    canvas.scale(camera.config.zoom);
    canvas.translate(-camera.position.dx, -camera.position.dy);

    for (final comp in children) {
      renderComponent(canvas, comp);
    }

    canvas.restore();
  }

  /// This renders a single component obeying BaseGame rules.
  ///
  /// It translates the camera unless hud, call the render method and restore the canvas.
  /// This makes sure the canvas is not messed up by one component and all components render independently.
  void renderComponent(Canvas canvas, Component comp) {
    if (comp is GameComponent) {
      if (!comp.isHud && !comp.isVisible) return;
    }

    canvas.save();

    if (comp.isHud) {
      canvas.translate(camera.position.dx, camera.position.dy);
      canvas.scale(1 / camera.config.zoom);
      canvas.translate(-size.x / 2, -size.y / 2);
    }

    comp.renderTree(canvas);

    if (debugMode) {
      comp.renderDebugMode(canvas);
    }

    canvas.restore();
  }

  @override
  Future<void> add(Component component) {
    if (component is BonfireHasGameRef) {
      (component as BonfireHasGameRef).gameRef = this;
    }
    return super.add(component);
  }

  @override
  Future<void> addAll(List<Component> components) {
    components.forEach((element) {
      if (element is BonfireHasGameRef) {
        (element as BonfireHasGameRef).gameRef = this;
      }
    });
    return super.addAll(components);
  }

  /// This implementation of update updates every component in the list.
  ///
  /// It also actually adds the components that were added by the [addLater] method, and remove those that are marked for destruction via the [Component.destroy] method.
  /// You can override it further to add more custom behaviour.
  @override
  void update(double dt) {
    camera.update(dt);
    super.update(dt);
  }

  /// Verify if the Component contain gestures.
  bool _hasGesture(Component c) {
    return ((c is GameComponent && c.isVisible) || c.isHud) &&
        (c is PointerDetectorHandler &&
            (c as PointerDetectorHandler).hasGesture());
  }

  /// reorder components by priority
  void updateOrderPriority() {
    children.rebalanceAll();
    _highestPriority = children.last.priority;
  }

  @override
  void detach() {
    if (kReleaseMode) {
      super.detach();
    }
  }

  @override
  void attach(owner, gameRenderBox) {
    if (!kReleaseMode && !isAttached) {
      super.attach(owner, gameRenderBox);
    } else if (kReleaseMode) {
      super.attach(owner, gameRenderBox);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    for (final child in children) {
      child.onGameResize(size);
    }
    super.onGameResize(size);
  }
}
