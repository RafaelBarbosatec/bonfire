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

/// `BonfireGame` is abstract; `BonfireWithCollision` is the concrete game used
/// by `BonfireWidget`, and it builds the viewport hud layers in its
/// constructor just like any other `BonfireGame`.
class _TestGame extends BonfireWithCollision {
  _TestGame()
      : super(
          context: _FakeBuildContext(),
          map: WorldMap(const []),
          configDefault: BonfireCollisionConfigDefault(),
        );
}

/// Regression test for the `Bad state: No element` crash reported when a
/// `WorldMapByTiled` registers its lighting occluders in `onLoad`.
///
/// While Flame mounts a component subtree it removes every child and re-adds
/// them one by one (`Component._reAddChildren`), so `camera.viewport.children`
/// is temporarily empty. `BonfireGame.lighting` used to search that list on
/// every read, which threw when a component touched it during `onLoad`.
void main() {
  group('BonfireGame hud layers', () {
    test('lighting is resolvable while the viewport children are re-added', () {
      final game = _TestGame();

      final lighting = game.lighting;
      // Same thing `_reAddChildren` does while mounting: the layer leaves the
      // viewport children for a moment.
      (lighting as GameComponent).removeFromParent();

      expect(game.lighting, same(lighting));
    });

    test('color filter is resolvable while the viewport children are re-added',
        () {
      final game = _TestGame();

      final colorFilter = game.colorFilter;
      (colorFilter as GameComponent).removeFromParent();

      expect(game.colorFilter, same(colorFilter));
    });
  });
}
