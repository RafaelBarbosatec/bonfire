import 'package:flutter/painting.dart';

/// Maps a single pixel "code" (a character used inside [PixelArt] rows) to a
/// [Color].
///
/// The code `'.'` is reserved by convention to mean "transparent pixel" and
/// does not need an entry here. If you do want `'.'` to render as an actual
/// color, just add it explicitly to the palette and that will take priority.
typedef PixelPalette = Map<String, Color>;
