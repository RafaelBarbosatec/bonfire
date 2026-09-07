import 'package:bonfire/base/game_component.dart';
import 'package:bonfire/mixins/tile_recognizer/tile_recognizer_api.dart';

export 'tile_recognizer_api.dart';

/// Mixin that provides map tile recognition below the component.
///
/// Access all tile querying functionality through the [tileRecognizer] API object.
mixin TileRecognizer on GameComponent {
  late final TileRecognizerApi tileRecognizer = TileRecognizerApi(this);
}
