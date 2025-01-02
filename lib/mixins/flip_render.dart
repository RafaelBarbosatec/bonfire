import 'package:bonfire/bonfire.dart';

mixin FlipRender on GameComponent {
  bool flipRenderVertically = false;
  bool flipRenderHorizonally = false;

  @override
  void render(Canvas canvas) {
    if (_needFlip) {
      _doFlip(canvas);
    }
    super.render(canvas);
    if (_needFlip) {
      canvas.restore();
    }
  }

  bool get _needFlip => flipRenderVertically || flipRenderHorizonally;

  void _doFlip(Canvas canvas) {
    final center = size / 2;
    canvas.save();
    canvas.translate(center.x, center.y);
    canvas.scale(
      flipRenderHorizonally ? -1 : 1,
      flipRenderVertically ? -1 : 1,
    );
    canvas.translate(-center.x, -center.y);
  }
}
