// ignore: constant_identifier_names
enum AcceptableAttackOriginEnum { ALL, ENEMY, PLAYER_AND_ALLY, NONE }

// ignore: constant_identifier_names
enum AttackOriginEnum { ENEMY, PLAYER_OR_ALLY, WORLD }

typedef LifeChangeCallback = void Function(double amount);
typedef LifeCallback = void Function();
typedef ReceiveDamageCallback = void Function(
  AttackOriginEnum attacker,
  double damage,
  dynamic identify,
);

/// API that manages all life/health logic for a game component.
///
/// Register listeners to react to life events:
/// ```dart
/// @override
/// void onMount() {
///   super.onMount();
///   life.initial(200);
///   life.onDieListener(_onDie);
///   life.onRemoveLifeListener(_onDamage);
/// }
/// ```
class LifeApi {
  /// Provides [isRemoving] state from the parent component.
  final bool Function() _isRemoving;

  LifeApi(this._isRemoving);

  /// Defines which attacker types can damage this component.
  AcceptableAttackOriginEnum receivesAttackFrom =
      AcceptableAttackOriginEnum.ALL;

  double _life = 100;
  double _maxLife = 100;
  bool _isDead = false;

  double get value => _life;
  double get max => _maxLife;
  bool get isDead => _isDead;

  final List<LifeChangeCallback> _onRemoveLifeCallbacks = [];
  final List<LifeChangeCallback> _onRestoreLifeCallbacks = [];
  final List<LifeCallback> _onDieCallbacks = [];
  final List<LifeCallback> _onReviveCallbacks = [];
  final List<ReceiveDamageCallback> _onReceiveDamageCallbacks = [];
  final List<LifeChangeCallback> _onInitialLifeCallbacks = [];
  final List<LifeChangeCallback> _onLifeUpdateCallbacks = [];

  void _updateLife(double value) {
    _life = value;
    for (final cb in _onLifeUpdateCallbacks) {
      cb(value);
    }
  }

  /// Registers a callback fired when life is removed.
  void onRemoveLifeListener(LifeChangeCallback callback) {
    _onRemoveLifeCallbacks.add(callback);
  }

  /// Registers a callback fired when life is restored.
  void onRestoreLifeListener(LifeChangeCallback callback) {
    _onRestoreLifeCallbacks.add(callback);
  }

  /// Registers a callback fired when the component dies.
  void onDieListener(LifeCallback callback) {
    _onDieCallbacks.add(callback);
  }

  /// Registers a callback fired when the component revives.
  void onReviveListener(LifeCallback callback) {
    _onReviveCallbacks.add(callback);
  }

  /// Registers a callback fired when the component receives damage.
  void onReceiveDamageListener(ReceiveDamageCallback callback) {
    _onReceiveDamageCallbacks.add(callback);
  }

  /// Registers a callback fired when [initial] is called.
  void onInitialLifeListener(LifeChangeCallback callback) {
    _onInitialLifeCallbacks.add(callback);
  }

  /// Registers a callback fired when [update] is called.
  void onLifeUpdateListener(LifeChangeCallback callback) {
    _onLifeUpdateCallbacks.add(callback);
  }

  /// Sets both current and max life to [value].
  void initial(double value) {
    _updateLife(value);
    _maxLife = value;
    for (final cb in _onInitialLifeCallbacks) {
      cb(value);
    }
  }

  /// Increases life by [value], capped at [max].
  void add(double value) {
    var newLife = _life + value;
    if (newLife > _maxLife) newLife = _maxLife;
    final restored = newLife - _life;
    _updateLife(newLife);
    if (restored > 0) {
      for (final cb in _onRestoreLifeCallbacks) {
        cb(restored);
      }
    }
    _verifyLimits();
  }

  /// Directly sets life to [value], optionally skipping die/revive checks.
  void update(double value, {bool verifyDieOrRevive = true}) {
    _updateLife(value);
    for (final cb in _onLifeUpdateCallbacks) {
      cb(value);
    }
    if (verifyDieOrRevive) {
      _verifyLimits();
    }
  }

  /// Reduces life by [value], floored at zero.
  void remove(double value) {
    var newLife = _life - value;
    if (newLife < 0) newLife = 0;
    final removed = _life - newLife;
    _updateLife(newLife);
    if (removed > 0) {
      for (final cb in _onRemoveLifeCallbacks) {
        cb(removed);
      }
    }
    _verifyLimits();
  }

  /// Applies [damage] from [attacker] if [checkCanReceiveDamage] returns true.
  ///
  /// Returns `true` if damage was applied.
  bool handleAttack(
    AttackOriginEnum attacker,
    double damage,
    dynamic identify,
  ) {
    if (!checkCanReceiveDamage(attacker)) return false;
    for (final cb in _onReceiveDamageCallbacks) {
      cb(attacker, damage, identify);
    }
    remove(damage);
    return true;
  }

  /// Returns `true` if this component can receive damage from [attacker].
  bool checkCanReceiveDamage(AttackOriginEnum attacker) {
    if (_isDead || _isRemoving()) return false;
    switch (receivesAttackFrom) {
      case AcceptableAttackOriginEnum.ALL:
        return true;
      case AcceptableAttackOriginEnum.ENEMY:
        return attacker == AttackOriginEnum.ENEMY ||
            attacker == AttackOriginEnum.WORLD;
      case AcceptableAttackOriginEnum.PLAYER_AND_ALLY:
        return attacker == AttackOriginEnum.PLAYER_OR_ALLY ||
            attacker == AttackOriginEnum.WORLD;
      case AcceptableAttackOriginEnum.NONE:
        return false;
    }
  }

  void _verifyLimits() {
    if (_life > 0 && _isDead) {
      _isDead = false;
      for (final cb in _onReviveCallbacks) {
        cb();
      }
    } else if (_life == 0 && !_isDead) {
      _isDead = true;
      for (final cb in _onDieCallbacks) {
        cb();
      }
    }
  }

  /// Releases all registered callbacks.
  void dispose() {
    _onRemoveLifeCallbacks.clear();
    _onRestoreLifeCallbacks.clear();
    _onDieCallbacks.clear();
    _onReviveCallbacks.clear();
    _onReceiveDamageCallbacks.clear();
    _onInitialLifeCallbacks.clear();
    _onLifeUpdateCallbacks.clear();
  }
}
