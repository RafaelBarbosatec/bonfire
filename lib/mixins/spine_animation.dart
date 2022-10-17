import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bonfire/bonfire.dart';
import 'package:flutter/cupertino.dart';

import 'package:spine_core/spine_core.dart' as core;

import '../spine/skeleton_animation.dart';


enum PlayState { paused, playing }

/// Mixin responsible for adding animations to movements
mixin SpineAnimation on Movement {
  /// How many steps we will use for calculate a render size by [animation].
  static const int countStepsForCalculateBounds = 100;

  static const List<int> quadTriangles = <int>[0, 1, 2, 2, 3, 0];
  static const int vertexSize = 2 + 2 + 4;

  final core.Color _tempColor = core.Color();
  double globalAlpha = 1.0;

  SkeletonAnimation? _skeleton;
  PlayState? _playState;
  core.Bounds? bounds;
  double? _frameSizeMultiplier;
  String? _animation;

  bool get _flipX => lastDirectionHorizontal == Direction.right;
  String? _currentAnimation;
  @override
  void update(double dt) {
    beginFrame(dt);
    super.update(dt);
  }
  void beginFrame(double dt) {
    _skeleton!
      ..updateState(dt)
      ..applyState()
      ..updateWorldTransform();
  }
  @override
  void render(ui.Canvas canvas) {
    // TODO: implement render
    super.render(canvas);
    if (_skeleton == null) {
      return;
    }
    draw(canvas);

    canvas.restore();
  }

  /// You can override [buildPaint] for add paint filters.
  /// For example, grayscale animation:
  /// ```
  /// @override
  /// Paint buildPaint() => super.buildPaint()
  ///   ..colorFilter = const ColorFilter.matrix(<double>[
  ///     0.2126, 0.7152, 0.0722, 0, 0,
  ///     0.2126, 0.7152, 0.0722, 0, 0,
  ///     0.2126, 0.7152, 0.0722, 0, 0,
  ///     0, 0, 0, 1, 0
  ///   ]);
  /// ```
  /// \see [defaultPaint]
  @mustCallSuper
  Paint buildPaint() {
    final Paint p = defaultPaint ?? Paint()
      ..isAntiAlias = true;
    return p..color = p.color.withOpacity(globalAlpha);
  }

  /// You can initialize or override [defaultPaint] for add paint filters.
  /// /// For example, sepia animation:
  /// ```
  /// overridePaint = Paint()
  ///   ..colorFilter = const ColorFilter.matrix(<double>[
  ///     0.393, 0.769, 0.189, 0, 0,
  ///     0.349, 0.686, 0.168, 0, 0,
  ///     0.272, 0.534, 0.131, 0, 0,
  ///     0, 0, 0, 1, 0,
  ///   ]);
  /// ```
  /// \see [buildPaint]
  Paint? defaultPaint;

  SkeletonAnimation get skeleton => _skeleton!;

  set skeleton(SkeletonAnimation value) {
    if (value == _skeleton) {
      return;
    }
    _skeleton = value;
    if (_skeleton != null) bounds = _calculateBounds();
  }
  PlayState get playState => _playState ?? PlayState.playing;

  set playState(PlayState value) {
    if (value == _playState) {
      return;
    }
    _playState = value;
  }
  /// Нow many percent increase the size of the animation
  /// relative to the size of the first frame.
  double get frameSizeMultiplier => _frameSizeMultiplier ?? 0.0;

  set frameSizeMultiplier(double value) {
    if (_frameSizeMultiplier == value) {
      return;
    }
    _frameSizeMultiplier = value;
    if (_skeleton != null) {
      bounds = _calculateBounds();
    }
  }

  /// A start animation. We will use it for calculate bounds by frames.
  String? get animation {
    if (_animation != null) {
      return _animation;
    }
    if (skeleton.data.animations.isNotEmpty) {
      return skeleton.data.animations.first.name;
    }
    return null;
  }

  set animation(String? value) {
    if (_animation == value) {
      return;
    }
    _animation = value;
    if (_skeleton != null && animation != null) {
      skeleton.state.setAnimation(0, animation!, true);
      bounds = _calculateBounds();
    }
  }

  core.Bounds _calculateBounds() {
    late final core.Bounds bounds;
    if (_animation == null) {
      skeleton
        ..setToSetupPose()
        ..updateWorldTransform();
      final core.Vector2 offset = core.Vector2();
      final core.Vector2 size = core.Vector2();
      skeleton.getBounds(offset, size, <double>[]);
      bounds = core.Bounds(offset, size);
    } else {
      bounds = calculateBoundsByAnimation();
    }

    final core.Vector2 delta = core.Vector2(
      bounds.size.x * frameSizeMultiplier,
      bounds.size.y * frameSizeMultiplier,
    );

    return core.Bounds(
      core.Vector2(
        bounds.offset.x - delta.x / 2,
        bounds.offset.y - delta.y / 2,
      ),
      core.Vector2(
        bounds.size.x + delta.x,
        bounds.size.y + delta.y,
      ),
    );
  }

  /// \thanks https://github.com/EsotericSoftware/spine-runtimes/blob/3.7/spine-ts/player/src/Player.ts#L1169
  core.Bounds calculateBoundsByAnimation() {
    final core.Vector2 offset = core.Vector2();
    final core.Vector2 size = core.Vector2();
    if (animation == null) {
      return core.Bounds(offset, size);
    }

    final core.Animation? skeletonAnimation =
    skeleton.data.findAnimation(animation!);
    if (skeletonAnimation == null) {
      return core.Bounds(offset, size);
    }

    skeleton.state.clearTracks();
    skeleton
      ..setToSetupPose()
      ..updateWorldTransform();
    skeleton.state.setAnimationWith(0, skeletonAnimation, true);

    final double stepTime = skeletonAnimation.duration > 0.0
        ? skeletonAnimation.duration / countStepsForCalculateBounds
        : 0.0;
    double minX = double.maxFinite;
    double maxX = -double.maxFinite;
    double minY = double.maxFinite;
    double maxY = -double.maxFinite;

    for (int i = 0; i < countStepsForCalculateBounds; ++i) {
      skeleton.state
        ..update(stepTime)
        ..apply(skeleton);
      skeleton
        ..updateWorldTransform()
        ..getBounds(offset, size, <double>[]);

      minX = math.min(offset.x, minX);
      maxX = math.max(offset.x + size.x, maxX);
      minY = math.min(offset.y, minY);
      maxY = math.max(offset.y + size.y, maxY);
    }

    offset
      ..x = minX
      ..y = minY;
    size
      ..x = maxX - minX
      ..y = maxY - minY;

    return core.Bounds(offset, size);
  }



  void draw(ui.Canvas canvas) {
    canvas
      ..save()
      ..translate(center.x, center.y);

    canvas
      ..scale(size.x/_skeleton!.width)       ///这里应该转为
      ..scale(_flipX ? 1 : -1, -1);
    _drawImages(canvas, _skeleton!);
  }

  void _drawImages(ui.Canvas canvas, SkeletonAnimation skeleton) {
    final Paint paint = Paint();
    final List<core.Slot> drawOrder = skeleton.drawOrder;

    canvas.save();

    final int n = drawOrder.length;

    for (int i = 0; i < n; i++) {
      final core.Slot slot = drawOrder[i];
      if(slot.getAttachment()==null){
        continue;
      }
      final core.Attachment attachment = slot.getAttachment()!;
      core.RegionAttachment regionAttachment;
      core.TextureAtlasRegion region;
      ui.Image image;

      if (attachment is! core.RegionAttachment) {
        continue;
      }

      regionAttachment = attachment;
      region = regionAttachment.region as core.TextureAtlasRegion;
      image = region.texture?.image;

      final core.Skeleton skeleton = slot.bone.skeleton;
      final core.Color skeletonColor = skeleton.color;
      final core.Color slotColor = slot.color;
      final core.Color regionColor = regionAttachment.color;
      final double alpha = skeletonColor.a * slotColor.a * regionColor.a;
      final core.Color color = _tempColor
        ..set(
            skeletonColor.r * slotColor.r * regionColor.r,
            skeletonColor.g * slotColor.g * regionColor.g,
            skeletonColor.b * slotColor.b * regionColor.b,
            alpha);

      final core.Bone bone = slot.bone;
      double w = region.width.toDouble();
      double h = region.height.toDouble();

      canvas
        ..save()
        ..transform(Float64List.fromList(<double>[
          bone.a,
          bone.c,
          0.0,
          0.0,
          bone.b,
          bone.d,
          0.0,
          0.0,
          0.0,
          0.0,
          1.0,
          0.0,
          bone.worldX,
          bone.worldY,
          0.0,
          1.0
        ]))
        ..translate(regionAttachment.offset[0], regionAttachment.offset[1])
        ..rotate((regionAttachment.rotation) * math.pi / 180);

      final double atlasScale = (regionAttachment.width) / w;

      canvas
        ..scale(atlasScale * (regionAttachment.scaleX),
            atlasScale * (regionAttachment.scaleY))
        ..translate(w / 2, h / 2);
      if (regionAttachment.region.rotate) {
        final double t = w;
        w = h;
        h = t;
        canvas.rotate(-math.pi / 2);
      }
      canvas
        ..scale(1.0, -1.0)
        ..translate(-w / 2, -h / 2);
      if (color.r != 1 || color.g != 1 || color.b != 1 || color.a != 1) {
        final int alpha = (color.a * 255).toInt();
        paint.color = paint.color.withAlpha(alpha);
      }
      canvas.drawImageRect(
          image,
          Rect.fromLTWH(region.x.toDouble(), region.y.toDouble(), w, h),
          Rect.fromLTWH(0.0, 0.0, w, h),
          paint);
      // if (_debugRendering!) {
      //   canvas.drawRect(Rect.fromLTWH(0.0, 0.0, w, h), paint);
      // }
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool moveUp(double speed, {bool notifyOnMove = true}) {
    _walk();
    return super.moveUp(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveRight(double speed, {bool notifyOnMove = true}) {
    _walk();
    return super.moveRight(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveDown(double speed, {bool notifyOnMove = true}) {
    _walk();
    return super.moveDown(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveLeft(double speed, {bool notifyOnMove = true}) {
    _walk();
    return super.moveLeft(speed, notifyOnMove: notifyOnMove);
  }

  @override
  bool moveUpLeft(double speedX, double speedY) {
    _walk();
    return super.moveUpLeft(speedX, speedY);
  }

  @override
  bool moveUpRight(double speedX, double speedY) {
    _walk();
    return super.moveUpRight(speedX, speedY);
  }

  @override
  bool moveDownRight(double speedX, double speedY) {
    _walk();
    return super.moveDownRight(speedX, speedY);
  }

  @override
  bool moveDownLeft(double speedX, double speedY) {
    _walk();
    return super.moveDownLeft(speedX, speedY);
  }

  @override
  void idle() {
    if (!isIdle) _stop();
    super.idle();
  }

  void setAnimation(String animationName, bool loop) {
    // if (_currentAnimation == 'walk' && animationName == 'walk') return;
    _currentAnimation = animationName;
    skeleton.state.setAnimation(1, animationName, loop);
  }

  void _stop() {
    if (isIdle) return;
    setAnimation('idle', false);
    skeleton.setToSetupPose();
  }

  void _walk() {
    if (isIdle) setAnimation('walk', true);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    idle();
  }

}
