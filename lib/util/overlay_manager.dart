import 'package:flame/game.dart';

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
/// on 09/06/22
class OverlayManager {
  final FlameGame game;

  OverlayManager(this.game);

  /// Marks the [overlayName] to be rendered.
  bool add(String overlayName) {
    return game.overlays.add(overlayName);
  }

  /// Marks [overlayNames] to be rendered.
  void addAll(Iterable<String> overlayNames) {
    return game.overlays.addAll(overlayNames);
  }

  /// Hides the [overlayName].
  bool remove(String overlayName) {
    return game.overlays.remove(overlayName);
  }

  /// Hides multiple overlays specified in [overlayNames].
  void removeAll(Iterable<String> overlayNames) {}

  /// Clear all active overlays.
  void clear() {
    game.overlays.clear();
  }

  /// The names of all currently active overlays.
  Set<String> get value => game.overlays.value;

  /// Returns if the given [overlayName] is active
  bool isActive(String overlayName) => game.overlays.isActive(overlayName);
}
