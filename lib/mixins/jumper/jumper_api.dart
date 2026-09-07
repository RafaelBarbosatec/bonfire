import 'package:bonfire/bonfire.dart';

enum JumpingStateEnum {
  up,
  down,
  idle,
}

typedef JumpStateChangedCallback = void Function(JumpingStateEnum state);

/// API for managing jump behavior
/// Encapsulates all jump state and logic
class JumperApi {
  final Movement _comp;

  // Configuration
  static const double _defaultJumpSpeed = 150.0;
  late int _maxJump;

  // State
  int _currentJumps = 0;
  bool _isJumping = false;
  JumpingStateEnum _jumpingState = JumpingStateEnum.idle;
  JumpingStateEnum? _lastDirectionJump = JumpingStateEnum.idle;
  int _tileCollisionCount = 0;

  // Public getters
  bool get isJumping => _isJumping;
  JumpingStateEnum get jumpingState => _jumpingState;
  int get currentJumps => _currentJumps;
  int get maxJump => _maxJump;

  // Callbacks for jump state changes
  final List<JumpStateChangedCallback> _jumpStateChangedCallbacks = [];

  final IntervalTick _tileCollisionTick = IntervalTick(
    100,
  );

  JumperApi(this._comp) {
    _maxJump = 1;
  }

  /// Setup maximum jumps allowed
  void setMaxJump(int maxJump) {
    _maxJump = maxJump;
  }

  /// Register a callback for jump state changes
  void onJumpStateChangedListener(JumpStateChangedCallback callback) {
    _jumpStateChangedCallbacks.add(callback);
  }

  /// Execute a jump with optional speed override
  /// [jumpSpeed] - speed of the jump (pixels per second)
  /// [force] - if true, jump even if already jumping at max jumps
  void jump({double? jumpSpeed, bool force = false}) {
    if (!_isJumping || _currentJumps < _maxJump || force) {
      _currentJumps++;
      _comp.moveUp(speed: jumpSpeed ?? _defaultJumpSpeed);
      _isJumping = true;
    }
  }

  /// Reset jump state (called when landing)
  void _resetJump() {
    _currentJumps = 0;
    _isJumping = false;
  }

  /// Handle movement blocked by collision
  void handleMovementBlocked(
    PositionComponent other,
    CollisionData collisionData,
  ) {
    if (_isJumping && collisionData.direction.isDownSide) {
      _resetJump();
    }
  }

  /// Handle collision start (increment tile collision counter)
  void handleCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    ++_tileCollisionCount;
    _tileCollisionTick.reset();
  }

  /// Handle collision end (decrement tile collision counter)
  void handleCollisionEnd(PositionComponent other) {
    if (--_tileCollisionCount == 0) {
      _tileCollisionTick.reset();
    }
  }

  /// Update jump state every frame
  void update(double dt) {
    _updateCollisionDetection(dt);
    _notifyJumpStateChange();
  }

  /// Check if character landed on ground or is in air
  void _updateCollisionDetection(double dt) {
    final tick = _tileCollisionTick.update(
      dt,
    );
    if (tick) {
      if (!_isJumping &&
          _tileCollisionCount == 0 &&
          _comp.velocity.y.abs() > 0.1) {
        _isJumping = true;
      }
    }
  }

  /// Notify if jump state changed (up/down/idle)
  void _notifyJumpStateChange() {
    JumpingStateEnum newDirection;
    if (_isJumping) {
      if (_comp.direction.isDownSide) {
        newDirection = JumpingStateEnum.down;
      } else {
        newDirection = JumpingStateEnum.up;
      }
    } else {
      newDirection = JumpingStateEnum.idle;
    }
    if (newDirection != _lastDirectionJump) {
      _lastDirectionJump = newDirection;
      _jumpingState = newDirection;
      _notifyJumpStateChanged(newDirection);
    }
  }

  /// Call all registered callbacks
  void _notifyJumpStateChanged(JumpingStateEnum state) {
    for (final callback in _jumpStateChangedCallbacks) {
      callback(state);
    }
  }

  /// Clean up all listeners
  void dispose() {
    _jumpStateChangedCallbacks.clear();
  }
}
