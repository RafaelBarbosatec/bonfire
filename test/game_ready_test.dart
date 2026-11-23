import 'dart:async';

import 'package:bonfire/base/bonfire_with_collision.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The game constructor stores the [BuildContext] but the tests never touch
/// Flutter-dependent APIs, so a fake is enough.
class _FakeBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// A component whose `onLoad` only completes once [finishLoading] is called,
/// simulating something like `F1Car` awaiting `SpriteStack.load(...)` inside
/// `onLoad`.
class _SlowLoadingComponent extends GameComponent {
  final _completer = Completer<void>();

  void finishLoading() => _completer.complete();

  @override
  Future<void> onLoad() async {
    await _completer.future;
    await super.onLoad();
  }
}

class _TestGame extends BonfireWithCollision {
  _TestGame({required GameComponent slowComponent, required this.onGameReady})
      : super(
          context: _FakeBuildContext(),
          map: WorldMap(const []),
          configDefault: BonfireCollisionConfigDefault(),
          components: [slowComponent],
          onReady: (_) => onGameReady(),
        );

  final VoidCallback onGameReady;
}

/// Mimics `GameWidgetState.loaderFuture`: `onGameResize` must happen before
/// `load()`/`mount()`, since `Component._startLoading` asserts `hasLayout`.
Future<_TestGame> _bootGame(
  GameComponent slowComponent,
  VoidCallback onReady,
) async {
  final game = _TestGame(slowComponent: slowComponent, onGameReady: onReady);
  game.onGameResize(Vector2(800, 600));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
  return game;
}

/// Runs a handful of update ticks, giving pending futures/microtasks a chance
/// to resolve, without using `FlameGame.ready()` (which loops forever while a
/// component is intentionally still loading, as in these tests).
Future<void> _pump(_TestGame game, {int times = 10}) async {
  for (var i = 0; i < times; i++) {
    game.update(1 / 60);
    await Future<void>.delayed(Duration.zero);
  }
}

void main() {
  test(
    'onReady only fires after every initial component finishes loading '
    '(regression: the game used to become "ready" while a component '
    'onLoad - e.g. a Player loading sprites - was still pending)',
    () async {
      final slowComponent = _SlowLoadingComponent();
      var readyCalls = 0;
      final game = await _bootGame(slowComponent, () => readyCalls++);

      // Pump several frames while the slow component is still loading: other
      // components (like the map) may already be mounted, but the game must
      // not be "ready" yet.
      await _pump(game);
      expect(
        readyCalls,
        0,
        reason: 'onReady must not fire while a component is still loading',
      );
      expect(slowComponent.isMounted, isFalse);
      expect(game.map.isMounted, isTrue);

      // Let the slow component finish loading and give the engine a chance
      // to mount it and process the pending onReady future.
      slowComponent.finishLoading();
      await _pump(game);

      expect(slowComponent.isMounted, isTrue);
      expect(readyCalls, 1);
    },
  );
}
