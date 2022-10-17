import 'package:spine_core/spine_core.dart' as core;
import 'dart:ui' as ui;

class SubTexture extends core.Texture {
  SubTexture(ui.Image image) : super(image);

  @override
  void setFilters(
      core.TextureFilter? minFilter, core.TextureFilter? magFilter) {}
  @override
  void setWraps(core.TextureWrap? uWrap, core.TextureWrap? vWrap) {}
  @override
  void dispose() {}
}
