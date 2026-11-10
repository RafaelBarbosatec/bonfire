import 'package:bonfire/bonfire.dart';
import 'package:bonfire/color_filter/color_filter_component.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final game = BonfireGame(map: WorldMap(const []));

      final lighting = game.lighting;
      // Same thing `_reAddChildren` does while mounting: the layer leaves the
      // viewport children for a moment.
      (lighting as GameComponent).removeFromParent();

      expect(game.lighting, same(lighting));
    });

    test('color filter is resolvable while the viewport children are re-added',
        () {
      final game = BonfireGame(map: WorldMap(const []));

      final colorFilter = game.colorFilter;
      (colorFilter as GameComponent).removeFromParent();

      expect(game.colorFilter, same(colorFilter));
    });
  });
}
