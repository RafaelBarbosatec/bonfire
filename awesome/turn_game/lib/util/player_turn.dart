import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:turn_game/main.dart';
import 'package:turn_game/spritesheet/spritesheet_builder.dart';
import 'package:turn_game/util/turn_manager.dart';

abstract class PlayerTurn extends SimpleNpc
    with TapGesture, WithPathFinding, WithCollision, WithLife, WithLifeBar {
  late TurnManager turnManager;
  late Rect rectYoutGridPosition;
  final Paint rectPaint = Paint()..color = Colors.blue.withValues(alpha: 0.5);
  final Paint _rectPaintClick = Paint()
    ..color = Colors.white.withValues(alpha: 0.5);
  final Paint gridPaint = Paint()
    ..color = Colors.white.withValues(alpha: 0.5)
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke;

  final Paint gridAttackPaint = Paint()
    ..color = Colors.red.withValues(alpha: 0.5);
  Vector2 countTileRadiusMove = Vector2.all(1);
  Vector2 countTileRadiusAttack = Vector2.all(1);
  final List<Rect> _gridCanMove = [];
  final List<Rect> _gridCanAttack = [];
  bool isSelected = false;
  Rect? rectClick;

  ShapeHitbox? hitbox;

  void doAttackChar(PlayerTurn char);

  PlayerTurn({
    required super.position,
    required super.size,
    required super.animation,
  }) {
    rectYoutGridPosition = Rect.fromLTWH(x, y, tileSize.x, tileSize.y);
    pathFinding.setup(
      pathLineColor: Colors.transparent,
    );

    lifeBar.setup(
      borderWidth: 2,
      borderRadius: BorderRadius.circular(1),
    );
  }

  @override
  Future<void> onLoad() {
    add(
      hitbox = RectangleHitbox(
        size: size / 1.5,
        position: size / 6,
      ),
    );
    return super.onLoad();
  }

  @override
  void onMount() {
    turnManager = TurnManager.instance;
    life.onReceiveDamageListener(_onReceiveDamage);
    life.onDieListener(_onDie);
    super.onMount();
  }

  @override
  void onTap() {
    if (isSelected) {
      turnManager.selectCharacter(null);
      gameRef.camera.stop();
    } else {
      bool changed = turnManager.selectCharacter(this);
      if (changed) {
        meveCameraToMe();
      }
    }
    _calculateAttackAndMoveGrid();
  }

  void meveCameraToMe() {
    gameRef.camera.moveToTargetAnimated(
      target: this,
      effectController: EffectController(duration: 1),
    );
  }

  @override
  bool handlerPointerDown(PointerDownEvent event) {
    if (isSelected) {
      final worldPosition = gameRef.screenToWorld(event.position.toVector2());
      _checkIfMove(worldPosition);
      _checkIfAttack(worldPosition);
      _getRectClick(worldPosition);
    }
    return super.handlerPointerDown(event);
  }

  @override
  bool handlerPointerUp(PointerUpEvent event) {
    rectClick = null;
    return super.handlerPointerUp(event);
  }

  @override
  void render(Canvas canvas) {
    if (isSelected) {
      canvas.save();
      canvas.translate(-x, -y);
      if (!pathFinding.isMoving) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            rectYoutGridPosition,
            const Radius.circular(4),
          ),
          rectPaint,
        );
      }
      _renderMoveGrid(canvas);
      _renderAttackGrid(canvas);
      if (rectClick != null) {
        canvas.drawRect(
          rectClick!,
          _rectPaintClick,
        );
      }
      canvas.restore();
    }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    isSelected = turnManager.isYourTurn(this);
    double xGrid = absoluteCenter.x ~/ tileSize.x * tileSize.x;
    double yGrid = absoluteCenter.y ~/ tileSize.y * tileSize.y;
    rectYoutGridPosition = Rect.fromLTWH(xGrid, yGrid, size.x, size.y);
    super.update(dt);
  }

  void _calculateGridCanMove() {
    _gridCanMove.clear();
    double xGrid = rectYoutGridPosition.left;
    double yGrid = rectYoutGridPosition.top;

    double deslocamentoX = countTileRadiusMove.x * tileSize.x;
    double deslocamentoY = countTileRadiusMove.y * tileSize.y;

    double startXGrid = xGrid - deslocamentoX;
    double startYGrid = yGrid - deslocamentoY;

    int sizeX = countTileRadiusMove.x.toInt() * 2 + 1;
    int sizeY = countTileRadiusMove.y.toInt() * 2 + 1;

    List.generate(sizeY, (indexY) {
      List.generate(
        sizeX,
        (indexX) {
          var rect = Rect.fromLTWH(
            startXGrid + indexX * width,
            startYGrid + indexY * height,
            width,
            height,
          );
          bool isInCollision = _checkRectInCollision(rect);
          if (!isInCollision) {
            _gridCanMove.add(rect);
          }
        },
      );
    });
  }

  void _calculateGridCanAttack() {
    _gridCanAttack.clear();
    double xGrid = rectYoutGridPosition.left;
    double yGrid = rectYoutGridPosition.top;

    double deslocamentoX = countTileRadiusAttack.x * tileSize.x;
    double deslocamentoY = countTileRadiusAttack.y * tileSize.y;

    double startXGrid = xGrid - deslocamentoX;
    double startYGrid = yGrid - deslocamentoY;

    int sizeX = countTileRadiusAttack.x.toInt() * 2 + 1;
    int sizeY = countTileRadiusAttack.y.toInt() * 2 + 1;

    List.generate(sizeY, (indexY) {
      List.generate(
        sizeX,
        (indexX) {
          _gridCanAttack.add(
            Rect.fromLTWH(
              startXGrid + indexX * width,
              startYGrid + indexY * height,
              width,
              height,
            ),
          );
        },
      );
    });
  }

  void _checkIfAttack(Vector2 worldPosition) {
    final findAttack = _gridCanAttack.where((element) {
      return element.contains(worldPosition.toOffset());
    });

    if (findAttack.isNotEmpty) {
      final players = gameRef.query<PlayerTurn>().where((element) {
        return element.rectCollision.overlaps(findAttack.first.deflate(2));
      });

      for (var p in players) {
        if (p != this) {
          doAttackChar(p);
        }
      }
    }
  }

  void _checkIfMove(Vector2 worldPosition) {
    final find = _gridCanMove.where((element) {
      return element.contains(worldPosition.toOffset());
    });

    if (find.isNotEmpty) {
      final collisions = gameRef.collisions().where((element) {
        return element != hitbox &&
            element.toRect().overlaps(find.first.deflate(2));
      });

      if (!collisions.isNotEmpty) {
        pathFinding.moveToPosition(
          worldPosition,
          onFinish: () {
            _calculateAttackAndMoveGrid();
            turnManager.doAction();
          },
        );
      }
    }
  }

  void _onReceiveDamage(
    AttackOriginEnum attacker,
    double damage,
    dynamic identify,
  ) {
    if (isDead || damage == 0) {
      return;
    }
    showDamage(damage, config: TextStyle(fontSize: tileSize.x / 2));
    var lastDirection = hDirection;
    if (lastDirection == Direction.left) {
      animation?.playOnce(
        animation!.others[SpriteSheetBuilder.ANIMATION_HITED_LEFT]!,
      );
    } else {
      animation?.playOnce(
        animation!.others[SpriteSheetBuilder.ANIMATION_HITED_RIGHT]!,
      );
    }
  }

  void _onDie() {
    var lastDirection = hDirection;
    if (lastDirection == Direction.left) {
      animation?.playOnce(
        animation!.others[SpriteSheetBuilder.ANIMATION_DIE_LEFT]!,
        runToTheEnd: true,
        onFinish: removeFromParent,
      );
    } else {
      animation?.playOnce(
        animation!.others[SpriteSheetBuilder.ANIMATION_DIE_RIGHT]!,
        onFinish: removeFromParent,
        runToTheEnd: true,
      );
    }
  }

  void _calculateAttackAndMoveGrid() {
    _calculateGridCanMove();
    _calculateGridCanAttack();
  }

  void _renderMoveGrid(Canvas canvas) {
    for (var element in _gridCanMove) {
      canvas.drawRect(element, gridPaint);
    }
  }

  void _renderAttackGrid(Canvas canvas) {
    for (var element in _gridCanAttack) {
      canvas.drawCircle(
        element.center,
        tileSize.x / 4.5,
        gridAttackPaint,
      );
    }
  }

  void _getRectClick(Vector2 worldPosition) {
    double xGrid = worldPosition.x ~/ tileSize.x * tileSize.x;
    double yGrid = worldPosition.y ~/ tileSize.y * tileSize.y;
    rectClick = Rect.fromLTWH(xGrid, yGrid, tileSize.x, tileSize.y);
  }

  bool _checkRectInCollision(Rect rect) {
    return gameRef.collisions(onlyVisible: true).where((element) {
      return element.containsPoint(rect.center.toVector2());
    }).isNotEmpty;
  }
}
