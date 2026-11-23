import 'package:bonfire/map/pixel_tileset/pixel_art.dart';

/// Describes one named tile of a [PixelTileset]: either a single static
/// [PixelArt], or a list of frames to be played back as an animation.
class PixelTile {
  /// The frames that make up this tile. A static tile has a single frame.
  final List<PixelArt> frames;

  /// Time (in seconds) each frame is shown, only used when [isAnimated].
  final double stepTime;

  /// When `true`, [PixelTileset.tile] adds a full-tile [RectangleHitbox] to
  /// the generated [Tile] by default (can still be overridden per call).
  final bool collision;

  final String? tileClass;
  final Map<String, dynamic>? properties;

  /// A static tile, drawn from a single [PixelArt].
  PixelTile.single(
    PixelArt art, {
    this.collision = false,
    this.tileClass,
    this.properties,
  })  : frames = [art],
        stepTime = 0;

  /// An animated tile, cycling through [frames] every [stepTime] seconds.
  PixelTile.animated(
    this.frames, {
    required this.stepTime,
    this.collision = false,
    this.tileClass,
    this.properties,
  }) {
    if (frames.isEmpty) {
      throw ArgumentError('PixelTile.animated: `frames` cannot be empty.');
    }
  }

  bool get isAnimated => frames.length > 1;
}
