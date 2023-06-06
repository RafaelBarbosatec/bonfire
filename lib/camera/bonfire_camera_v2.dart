import 'package:bonfire/bonfire.dart';
import 'package:flame/experimental.dart';

class BonfireCameraV2 extends CameraComponent with BonfireHasGameRef {
  double _spacingMap = 32.0;
  final CameraConfig config;
  BonfireCameraV2({
    Iterable<Component>? childen,
    required this.config,
    super.hudComponents,
    super.viewport,
  }) : super(world: World(children: childen)) {
    viewfinder.zoom = config.zoom;
    viewfinder.angle = config.angle;
    if (config.target != null) {
      follow(config.target!, snap: true);
    }
  }

  Rect get cameraRectWithSpacing => visibleWorldRect.inflate(_spacingMap);

  Vector2 get position => viewfinder.position;
  Vector2 get topleft => Vector2(
        position.x - visibleWorldRect.width / 2,
        position.y - visibleWorldRect.height / 2,
      );

  double get zoom => viewfinder.zoom;

  void updateSpacingVisibleMap(double space) {
    _spacingMap = space;
  }

  void moveTop(double displacement) {
    moveTo(viewfinder.position.translated(0, displacement * -1));
  }

  void moveRight(double displacement) {
    moveTo(viewfinder.position.translated(displacement, 0));
  }

  void moveLeft(double displacement) {
    moveTo(viewfinder.position.translated(displacement * -1, 0));
  }

  void moveDown(double displacement) {
    moveTo(viewfinder.position.translated(0, displacement));
  }

  void moveUp(double displacement) {
    moveTo(viewfinder.position.translated(displacement * -1, 0));
  }

  void moveToPositionAnimated({
    required Vector2 position,
    required EffectController effectController,
    Vector2? zoom,
    double? angle,
    Function()? onComplete,
  }) {
    stop();
    final moveToEffect = MoveToEffect(
      position,
      effectController,
      onComplete: onComplete,
    );
    viewfinder.add(moveToEffect);
    if (zoom != null) {
      final zoomEffect = ScaleEffect.to(
        zoom,
        effectController,
      );
      zoomEffect.removeOnFinish = true;
      viewfinder.add(zoomEffect);
    }
    if (angle != null) {
      final rotateEffect = RotateEffect.to(
        angle,
        effectController,
      );
      rotateEffect.removeOnFinish = true;
      viewfinder.add(rotateEffect);
    }
  }

  void moveToTargetAnimated({
    required GameComponent target,
    required EffectController effectController,
    Vector2? zoom,
    double? angle,
    Function()? onComplete,
  }) {
    moveToPositionAnimated(
      position: target.absolutePosition,
      effectController: effectController,
      zoom: zoom,
      angle: angle,
      onComplete: onComplete,
    );
  }

  void moveToPlayer() {
    gameRef.player.let((i) {
      follow(i, snap: true);
    });
  }

  @override
  void follow(
    PositionProvider target, {
    double maxSpeed = double.infinity,
    bool horizontalOnly = false,
    bool verticalOnly = false,
    bool snap = false,
  }) {
    stop();
    viewfinder.add(
      MyFollowBehavior(
        target: target,
        movementWindow: config.movementWindow,
        owner: viewfinder,
        maxSpeed: config.speed,
      ),
    );
    viewfinder.position = target.position;
  }

  void moveToPlayerAnimated({
    required EffectController effectController,
    Function()? onComplete,
    double? zoom,
    double? angle,
  }) {
    gameRef.player.let((i) {
      moveToTargetAnimated(
        target: i,
        effectController: effectController,
        zoom: Vector2(zoom ?? 1, zoom ?? 1),
        angle: angle,
        onComplete: () {
          onComplete?.call();
          follow(i);
        },
      );
    });
  }

  void animateZoom({
    required Vector2 zoom,
    required EffectController effectController,
    Function()? onComplete,
  }) {
    final zoomEffect = ScaleEffect.to(
      zoom,
      effectController,
      onComplete: onComplete,
    );
    zoomEffect.removeOnFinish = true;
    viewfinder.add(zoomEffect);
  }

  void animateAngle({
    required double angle,
    required EffectController effectController,
    Function()? onComplete,
  }) {
    final rotateEffect = RotateEffect.to(
      angle,
      effectController,
      onComplete: onComplete,
    );
    rotateEffect.removeOnFinish = true;
    viewfinder.add(rotateEffect);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    updatesetBounds();
  }

  void updatesetBounds() {
    if (config.moveOnlyMapArea && viewfinder.isMounted) {
      setBounds(
        Rectangle.fromRect(
          gameRef.map.getRect().deflatexy(
                visibleWorldRect.width / 2,
                visibleWorldRect.height / 2,
              ),
        ),
      );
    }
  }
}

class MyFollowBehavior extends Component {
  final Vector2 movementWindow;
  MyFollowBehavior({
    required PositionProvider target,
    required this.movementWindow,
    PositionProvider? owner,
    double maxSpeed = double.infinity,
    this.horizontalOnly = false,
    this.verticalOnly = false,
    super.priority,
  })  : _target = target,
        _owner = owner,
        _speed = maxSpeed,
        assert(maxSpeed > 0, 'maxSpeed must be positive: $maxSpeed'),
        assert(
          !(horizontalOnly && verticalOnly),
          'The behavior cannot be both horizontalOnly and verticalOnly',
        );

  PositionProvider get target => _target;
  final PositionProvider _target;

  PositionProvider get owner => _owner!;
  PositionProvider? _owner;

  double get maxSpeed => _speed;
  final double _speed;

  final bool horizontalOnly;
  final bool verticalOnly;

  @override
  void onMount() {
    if (_owner == null) {
      assert(
        parent is PositionProvider,
        'Can only apply this behavior to a PositionProvider',
      );
      _owner = parent! as PositionProvider;
    }
  }

  @override
  void update(double dt) {
    var delta = target.position - owner.position;
    if (verticalOnly) {
      delta = delta.copyWith(x: 0);
    }

    if (horizontalOnly) {
      delta = delta.copyWith(y: 0);
    }

    final distance = delta.length;
    var scale = dt;
    if (distance > _speed * dt) {
      scale = _speed * dt / distance;
    }

    owner.position = owner.position.clone()
      ..lerp(owner.position + delta, scale);

    // final delta = target.position - owner.position;
    // final distance = delta.length;
    // if (horizontalOnly) {
    //   delta.y = 0;
    // }

    // if (verticalOnly) {
    //   delta.x = 0;
    // }

    // if (distance > _speed * dt) {
    //   delta.scale(_speed * dt / distance);
    // }
    // owner.position = delta..add(owner.position);
  }
}
