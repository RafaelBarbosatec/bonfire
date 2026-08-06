import 'package:bonfire/base/game_component.dart';

/// API that handles render flipping for a component.
class FlipRenderApi {
  final GameComponent comp;

  bool _vertically = false;
  bool _horizontally = false;

  FlipRenderApi(this.comp);

  bool get isFlipped => _vertically || _horizontally;

  bool get isFlippedVertically => _vertically;

  bool get isFlippedHorizontally => _horizontally;

  /// Applies the flip transform to the [canvas].
  void flipVertically() {
    _vertically = !_vertically;
  }

  void flipHorizontally() {
    _horizontally = !_horizontally;
  }

  bool get vertically => _vertically;
  bool get horizontally => _horizontally;
}
