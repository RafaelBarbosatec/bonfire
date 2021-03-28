import 'dart:math' as math;

import 'package:bonfire/base/custom_widget_builder.dart';
import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/util/camera/camera.dart';
import 'package:bonfire/util/gestures/drag_gesture.dart';
import 'package:bonfire/util/gestures/tap_gesture.dart';
import 'package:bonfire/util/mixins/pointer_detector_mixin.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/composed_component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/game/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';

abstract class BaseGamePointerDetector extends Game with PointerDetector {
  bool _isPause = false;
  final CustomWidgetBuilder widgetBuilder = CustomWidgetBuilder();
  Camera gameCamera = Camera();

  /// The list of components to be updated and rendered by the base game.
  OrderedSet<Component> components =
      OrderedSet(Comparing.on((c) => c.priority()));

  /// Components added by the [addLater] method
  final List<Component> _addLater = [];

  /// Current screen size, updated every resize via the [resize] method hook
  Size size;

  /// List of deltas used in debug mode to calculate FPS
  final List<double> _dts = [];

  Iterable<GameComponent> get _gesturesComponents =>
      components.where((c) => _hasGesture(c)).cast<GameComponent>();

  Iterable<PointerDetector> get _pointerDetectorComponents =>
      components.where((c) => (c is PointerDetector)).cast();

  void onPointerCancel(PointerCancelEvent event) {
    _pointerDetectorComponents.forEach((c) => c.onPointerCancel(event));
  }

  void onPointerUp(PointerUpEvent event) {
    for (final c in _gesturesComponents) {
      c.handlerPointerUp(event.pointer, event.localPosition);
    }
    for (final c in _pointerDetectorComponents) {
      c.onPointerUp(event);
    }
  }

  void onPointerMove(PointerMoveEvent event) {
    for (final c in _gesturesComponents) {
      if (c is DragGesture) {
        c.handlerPointerMove(event.pointer, event.localPosition);
      }
    }
    for (final c in _pointerDetectorComponents) {
      c.onPointerMove(event);
    }
  }

  void onPointerDown(PointerDownEvent event) {
    for (final c in _gesturesComponents) {
      c.handlerPointerDown(event.pointer, event.localPosition);
    }
    for (final c in _pointerDetectorComponents) {
      c.onPointerDown(event);
    }
  }

  /// This method is called for every component added, both via [add] and [addLater] methods.
  ///
  /// You can use this to setup your mixins, pre-calculate stuff on every component, or anything you desire.
  /// By default, this calls the first time resize for every component, so don't forget to call super.preAdd when overriding.
  @mustCallSuper
  void preAdd(Component c) {
    if (debugMode() && c is PositionComponent) {
      c.debugMode = true;
    }

    if (c is HasGameRef) {
      (c as HasGameRef).gameRef = this;
    }

    // first time resize
    if (size != null) {
      c.resize(size);
    }

    if (c is ComposedComponent) {
      c.components.forEach(preAdd);
    }
  }

  /// Registers a component to be added on the components on the next tick.
  ///
  /// Use this to add components in places where a concurrent issue with the update method might happen.
  /// Also calls [preAdd] for the component added, immediately.
  void add(Component c) {
    _addLater.add(c);
  }

  /// This implementation of render basically calls [renderComponent] for every component, making sure the canvas is reset for each one.
  ///
  /// You can override it further to add more custom behaviour.
  /// Beware of however you are rendering components if not using this; you must be careful to save and restore the canvas to avoid components messing up with each other.
  @override
  void render(Canvas canvas) {
    canvas.save();

    canvas.translate(size.width / 2, size.height / 2);
    canvas.scale(gameCamera.zoom);
    canvas.translate(-gameCamera.position.x, -gameCamera.position.y);

    components.forEach((comp) => renderComponent(canvas, comp));
    canvas.restore();
  }

  /// This renders a single component obeying BaseGame rules.
  ///
  /// It translates the camera unless hud, call the render method and restore the canvas.
  /// This makes sure the canvas is not messed up by one component and all components render independently.
  void renderComponent(Canvas canvas, Component comp) {
    if (!comp.loaded()) {
      return;
    } else if (comp is GameComponent) {
      if (!comp.isHud() && !comp.isVisibleInCamera()) return;
    }

    canvas.save();

    if (comp.isHud()) {
      canvas.translate(gameCamera.position.x, gameCamera.position.y);
      canvas.scale(1 / gameCamera.zoom);
      canvas.translate(-size.width / 2, -size.height / 2);
    }

    comp.render(canvas);
    canvas.restore();
  }

  /// This implementation of update updates every component in the list.
  ///
  /// It also actually adds the components that were added by the [addLater] method, and remove those that are marked for destruction via the [Component.destroy] method.
  /// You can override it further to add more custom behaviour.
  @override
  void update(double t) {
    if (_isPause) return;
    _addLater.forEach((c) {
      preAdd(c);
      components.add(c);
    });
    _addLater.clear();

    components.forEach((c) => c.update(t));
    components.removeWhere((c) => c.destroy());

    gameCamera.update();
  }

  void pause() {
    _isPause = true;
  }

  void resume() {
    _isPause = false;
  }

  bool get isGamePaused => _isPause;

  /// This implementation of resize passes the resize call along to every component in the list, enabling each one to make their decisions as how to handle the resize.
  ///
  /// It also updates the [size] field of the class to be used by later added components and other methods.
  /// You can override it further to add more custom behaviour, but you should seriously consider calling the super implementation as well.
  @override
  @mustCallSuper
  void resize(Size size) {
    this.size = size;
    components.forEach((c) => c.resize(size));
  }

  /// Returns whether this [Game] is in debug mode or not.
  ///
  /// Returns `false` by default. Override to use the debug mode.
  /// You can use this value to enable debug behaviors for your game, many components show extra information on screen when on debug mode
  bool debugMode() => false;

  /// Returns whether this [Game] is should record fps or not
  ///
  /// Returns `false` by default. Override to use the `fps` counter method.
  /// In recording fps, the [recordDt] method actually records every `dt` for statistics.
  /// Then, you can use the [fps] method to check the game FPS.
  bool recordFps() => false;

  /// This is a hook that comes from the RenderBox to allow recording of render times and statistics.
  @override
  void recordDt(double dt) {
    if (recordFps()) {
      _dts.add(dt);
    }
  }

  /// Returns the average FPS for the last [average] measures.
  ///
  /// The values are only saved if in debug mode (override [recordFps] to use this).
  /// Selects the last [average] dts, averages then, and returns the inverse value.
  /// So it's technically updates per second, but the relation between updates and renders is 1:1.
  /// Returns 0 if empty.
  double fps([int average = 1]) {
    final List<double> dts = _dts.sublist(math.max(0, _dts.length - average));
    if (dts.isEmpty) {
      return 0.0;
    }
    final double dtSum = dts.reduce((s, t) => s + t);
    final double averageDt = dtSum / average;
    return 1 / averageDt;
  }

  /// Returns the current time in seconds with microseconds precision.
  ///
  /// This is compatible with the `dt` value used in the [update] method.
  double currentTime() {
    return DateTime.now().microsecondsSinceEpoch.toDouble() /
        Duration.microsecondsPerSecond;
  }

  @override
  Widget get widget => widgetBuilder.build(this);

  bool _hasGesture(Component c) {
    return ((c is GameComponent && (c.isVisibleInCamera() || c.isHud())) &&
        ((c is TapGesture && c.enableTab) ||
            (c is DragGesture && (c).enableDrag)));
  }
}
