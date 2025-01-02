// ignore_for_file: implementation_imports, invalid_use_of_internal_member

import 'dart:async';

import 'package:bonfire/mixins/pointer_detector.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flame/src/game/game_widget/gesture_detector_builder.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef GameLoadingWidgetBuilder = Widget Function(
  BuildContext,
);

typedef GameErrorWidgetBuilder = Widget Function(
  BuildContext,
  Object error,
);

typedef OverlayWidgetBuilder<T extends Game> = Widget Function(
  BuildContext context,
  T game,
);

typedef GameFactory<T extends Game> = T Function();

/// A [StatefulWidget] that is in charge of attaching a [Game] instance into the
/// Flutter tree.
class ListenerGameWidget<T extends Game> extends StatefulWidget {
  /// The game instance which this widget will render, if the normal constructor
  /// is used.
  /// If the [ListenerGameWidget.controlled] constructor is used, this will
  /// aways be `null`.
  final T? game;

  /// A function that creates a [Game] that this widget will render.
  final GameFactory<T>? gameFactory;

  /// The text direction to be used in text elements in a game.
  final TextDirection? textDirection;

  /// Builder to provide a widget tree to be built while the Game's [Future]
  /// provided via `Game.onLoad` and `Game.onMount` is not resolved.
  /// By default this is an empty Container().
  final GameLoadingWidgetBuilder? loadingBuilder;

  /// If set, errors during the onLoad method will not be thrown
  /// but instead this widget will be shown. If not provided, errors are
  /// propagated up.
  final GameErrorWidgetBuilder? errorBuilder;

  /// Builder to provide a widget tree to be built between the game elements and
  /// the background color provided via [Game.backgroundColor].
  final WidgetBuilder? backgroundBuilder;

  /// A map to show widgets overlay.
  ///
  /// See also:
  /// - [ListenerGameWidget]
  /// - [Game.overlays]
  final Map<String, OverlayWidgetBuilder<T>>? overlayBuilderMap;

  /// The [FocusNode] to control the games focus to receive event inputs.
  /// If omitted, defaults to an internally controlled focus node.
  final FocusNode? focusNode;

  /// Whether the [focusNode] requests focus once the game is mounted.
  /// Defaults to true.
  final bool autofocus;

  final MouseCursor? mouseCursor;
  final List<String>? initialActiveOverlays;

  /// Renders a [game] in a flutter widget tree.
  ///
  /// Ex:
  /// ```
  /// // Inside a State...
  /// late MyGameClass game;
  ///
  /// @override
  /// void initState() {
  ///   super.initState();
  ///   game = MyGameClass();
  /// }
  /// ...
  /// Widget build(BuildContext  context) {
  ///   return GameWidget(
  ///     game: game,
  ///   )
  /// }
  /// ...
  /// ```
  ///
  /// It is also possible to render layers of widgets over the game surface with
  /// widget subtrees.
  ///
  /// To do that a [overlayBuilderMap] should be provided. The visibility of
  /// these overlays are controlled by [Game.overlays] property
  ///
  /// Ex:
  /// ```
  /// ...
  ///
  /// final game = MyGame();
  ///
  /// Widget build(BuildContext  context) {
  ///   return GameWidget(
  ///     game: game,
  ///     overlayBuilderMap: {
  ///       'PauseMenu': (ctx, game) {
  ///         return Text('A pause menu');
  ///       },
  ///     },
  ///   )
  /// }
  /// ...
  /// game.overlays.add('PauseMenu');
  /// ```
  ListenerGameWidget({
    required T this.game,
    super.key,
    this.textDirection,
    this.loadingBuilder,
    this.errorBuilder,
    this.backgroundBuilder,
    this.overlayBuilderMap,
    this.initialActiveOverlays,
    this.focusNode,
    this.autofocus = true,
    this.mouseCursor,
    this.addRepaintBoundary = true,
  }) : gameFactory = null {
    _initializeGame(game!);
  }

  /// Whether the game should assume the behavior of a [RepaintBoundary],
  /// defaults to `true`.
  final bool addRepaintBoundary;

  /// Renders a [game] in a flutter widget tree alongside widgets overlays.
  ///
  /// To use overlays, the game subclass has to be mixed with HasWidgetsOverlay.
  @override
  ListenerGameWidgetState<T> createState() => ListenerGameWidgetState<T>();

  void _initializeGame(T game) {
    if (mouseCursor != null) {
      game.mouseCursor = mouseCursor!;
    }
    if (overlayBuilderMap != null) {
      for (final kv in overlayBuilderMap!.entries) {
        game.overlays.addEntry(
          kv.key,
          (ctx, game) => kv.value(ctx, game as T),
        );
      }
    }
    if (initialActiveOverlays != null) {
      game.overlays.addAll(initialActiveOverlays!);
    }
  }
}

class ListenerGameWidgetState<T extends Game>
    extends State<ListenerGameWidget<T>> {
  late T currentGame;

  Future<void> get loaderFuture => _loaderFuture ??= (() async {
        final game = currentGame;
        assert(game.hasLayout);
        await game.load();
        game.mount();
        if (!game.paused) {
          game.update(0);
        }
      })();

  Future<void>? _loaderFuture;

  late FocusNode _focusNode;

  /// The number of `build()` functions currently executing.
  int _buildDepth = 0;

  /// If true, then a fresh build will be scheduled after the current one
  /// completes. This should only be set to true when the [_buildDepth] is
  /// non-zero.
  bool _requiresRebuild = false;

  /// Helper method that arranges to have `_buildDepth > 0` while the [build] is
  /// executing, and then schedules a re-build if [_requiresRebuild] flag was
  /// raised during the build.
  ///
  /// This is needed because our build function invokes user code, which in turn
  /// may change some of the [Game]'s properties which would require the
  /// [ListenerGameWidget] to be rebuilt. However, Flutter doesn't allow widgets
  /// to be
  /// marked dirty while they are building. So, this method is needed to avoid
  /// such a limitation and ensure that the user code can set [Game]'s
  /// properties freely, and that they will be propagated to the
  ///  [ListenerGameWidget] at the earliest opportunity.
  Widget _protectedBuild(Widget Function() build) {
    late final Widget result;
    try {
      _buildDepth++;
      result = build();
    } finally {
      _buildDepth--;
    }
    if (_requiresRebuild && _buildDepth == 0) {
      Future.microtask(_onGameStateChange);
    }
    return result;
  }

  void _onGameStateChange() {
    if (_buildDepth > 0) {
      _requiresRebuild = true;
    } else {
      setState(() => _requiresRebuild = false);
    }
  }

  void initCurrentGame() {
    if (widget.game == null) {
      currentGame = widget.gameFactory!.call();
      widget._initializeGame(currentGame);
    } else {
      currentGame = widget.game!;
    }
    currentGame.addGameStateListener(_onGameStateChange);
    _loaderFuture = null;
  }

  /// Visible for testing for
  /// https://github.com/flame-engine/flame/issues/2771.
  @visibleForTesting
  static void initGameStateListener(
    Game currentGame,
    void Function() onGameStateChange,
  ) {
    currentGame.addGameStateListener(onGameStateChange);

    // See https://github.com/flame-engine/flame/issues/2771
    // for why we aren't using [WidgetsBinding.instance.lifecycleState].
    currentGame.lifecycleStateChange(AppLifecycleState.resumed);
  }

  /// [disposeCurrentGame] is called by two flutter events - `didUpdateWidget`
  /// and `dispose`.  When the parameter [callGameOnDispose] is true, the
  /// `currentGame`'s `onDispose` method will be called; otherwise, it will not.
  void disposeCurrentGame({bool callGameOnDispose = false}) {
    currentGame.removeGameStateListener(_onGameStateChange);
    currentGame.lifecycleStateChange(AppLifecycleState.paused);
    currentGame.finalizeRemoval();
    if (callGameOnDispose) {
      currentGame.onDispose();
    }
  }

  @override
  void initState() {
    super.initState();
    initCurrentGame();
    _focusNode = widget.focusNode ?? FocusNode();
    if (widget.autofocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(ListenerGameWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.game != widget.game) {
      disposeCurrentGame();
      initCurrentGame();
    }
  }

  @override
  void dispose() {
    super.dispose();
    disposeCurrentGame(callGameOnDispose: true);
    // If we received a focus node from the user, they are responsible
    // for disposing it
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode focusNode, KeyEvent event) {
    final game = currentGame;

    if (!_focusNode.hasPrimaryFocus) {
      return KeyEventResult.ignored;
    }

    if (game is KeyboardEvents) {
      return game.onKeyEvent(
        event,
        HardwareKeyboard.instance.logicalKeysPressed,
      );
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return _protectedBuild(() {
      Widget internalGameWidget = RenderGameWidget(
        game: currentGame,
        addRepaintBoundary: widget.addRepaintBoundary,
      );

      assert(
        !(currentGame is MultiTouchDragDetector && currentGame is PanDetector),
        'WARNING: Both MultiTouchDragDetector and a PanDetector detected. '
        'The MultiTouchDragDetector will override the PanDetector and it will '
        'not receive events',
      );

      internalGameWidget =
          currentGame.gestureDetectors.build(internalGameWidget);

      if (hasMouseDetectors(currentGame)) {
        internalGameWidget = applyMouseDetectors(
          currentGame,
          internalGameWidget,
        );
      }

      final stackedWidgets = <Widget>[internalGameWidget];
      _addBackground(context, stackedWidgets);
      _addOverlays(context, stackedWidgets);

      // We can use Directionality.maybeOf when that method lands on stable
      final textDir = widget.textDirection ?? TextDirection.ltr;

      return ClipRect(
        child: Listener(
          onPointerDown: currentGame is PointerDetector
              ? (currentGame as PointerDetector).onPointerDown
              : null,
          onPointerMove: currentGame is PointerDetector
              ? (currentGame as PointerDetector).onPointerMove
              : null,
          onPointerUp: currentGame is PointerDetector
              ? (currentGame as PointerDetector).onPointerUp
              : null,
          onPointerCancel: currentGame is PointerDetector
              ? (currentGame as PointerDetector).onPointerCancel
              : null,
          onPointerHover: currentGame is PointerDetector
              ? (currentGame as PointerDetector).onPointerHover
              : null,
          onPointerSignal: currentGame is PointerDetector
              ? (currentGame as PointerDetector).onPointerSignal
              : null,
          child: FocusScope(
            child: Focus(
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              descendantsAreFocusable: true,
              onKeyEvent: _handleKeyEvent,
              child: MouseRegion(
                cursor: currentGame.mouseCursor,
                child: Directionality(
                  textDirection: textDir,
                  child: ColoredBox(
                    color: currentGame.backgroundColor(),
                    child: LayoutBuilder(
                      builder: (_, BoxConstraints constraints) {
                        return _protectedBuild(() {
                          final size = constraints.biggest.toVector2();
                          if (size.isZero()) {
                            return widget.loadingBuilder?.call(context) ??
                                Container();
                          }
                          currentGame.onGameResize(size);
                          // This should only be called if the game has already
                          // been loaded (in the case of resizing for example),
                          // since update otherwise should be called after
                          // onMount.
                          if (!currentGame.paused && currentGame.isAttached) {
                            currentGame.update(0);
                          }
                          return FutureBuilder(
                            future: loaderFuture,
                            builder: (_, snapshot) {
                              if (snapshot.hasError) {
                                final errorBuilder = widget.errorBuilder;
                                if (errorBuilder == null) {
                                  throw Error.throwWithStackTrace(
                                    snapshot.error!,
                                    snapshot.stackTrace!,
                                  );
                                } else {
                                  return errorBuilder(context, snapshot.error!);
                                }
                              }

                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return Stack(children: stackedWidgets);
                              }

                              return widget.loadingBuilder?.call(context) ??
                                  const SizedBox.expand();
                            },
                          );
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _addBackground(BuildContext context, List<Widget> stackWidgets) {
    if (widget.backgroundBuilder != null) {
      final backgroundContent = KeyedSubtree(
        key: ValueKey(widget.game),
        child: widget.backgroundBuilder!(context),
      );
      stackWidgets.insert(0, backgroundContent);
    }
  }

  void _addOverlays(BuildContext context, List<Widget> stackWidgets) {
    stackWidgets.addAll(
      currentGame.overlays.buildCurrentOverlayWidgets(context),
    );
  }
}
