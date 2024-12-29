import 'package:bonfire/bonfire.dart';
import 'package:flutter/painting.dart';

class CameraParallax extends Parallax {
  CameraParallax(super.layers, {super.size, super.baseVelocity});

  static Future<Parallax> load(
    Iterable<ParallaxData> dataList, {
    Vector2? size,
    Vector2? baseVelocity,
    Vector2? velocityMultiplierDelta,
    ImageRepeat repeat = ImageRepeat.repeatX,
    Alignment alignment = Alignment.bottomLeft,
    LayerFill fill = LayerFill.height,
    Images? images,
    FilterQuality? filterQuality,
  }) async {
    final velocityDelta = velocityMultiplierDelta ?? Vector2.all(1.0);
    final layers = await Future.wait<ParallaxLayer>(
      dataList.mapIndexed((depth, data) async {
        final velocityMultiplier =
            List.filled(depth, velocityDelta).fold<Vector2>(
          velocityDelta,
          (previousValue, delta) => previousValue.clone()..multiply(delta),
        );
        final renderer = await data.load(
          repeat,
          alignment,
          fill,
          images,
          filterQuality,
        );
        return ParallaxLayer(
          renderer,
          velocityMultiplier: velocityMultiplier,
        );
      }),
    );
    return CameraParallax(
      layers,
      size: size,
      baseVelocity: baseVelocity,
    );
  }

  @override
  void update(double dt) {
    // super.update(dt);
  }

  // Used to avoid creating new Vector2 objects in the update-loop.
  final _delta = Vector2.zero();

  void moveParallax(Vector2 velocity, double dt) {
    for (final layer in layers) {
      layer.update(
        _delta
          ..setFrom(
            Vector2(baseVelocity.x * velocity.x, baseVelocity.y * velocity.y),
          )
          ..multiply(layer.velocityMultiplier)
          ..scale(dt),
        dt,
      );
    }
  }
}

extension IterableExtension<T> on Iterable<T> {
  /// Maps each element and its index to a new value.
  Iterable<R> mapIndexed<R>(R Function(int index, T element) convert) sync* {
    var index = 0;
    for (final element in this) {
      yield convert(index++, element);
    }
  }
}
