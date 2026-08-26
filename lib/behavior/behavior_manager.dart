import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';

/// Manages the execution of a list of [Behavior]s, processing one per frame and
/// advancing to the next one whenever the current behavior returns `true` from
/// [Behavior.process].
///
/// It is added automatically by the [UseBehavior] mixin, but you can also use
/// it directly:
///
/// ```dart
/// add(
///   BehaviorManager(
///     behaviors: [BCondition(...)],
///   ),
/// );
/// ```
class BehaviorManager extends Component with BonfireHasGameRef {
  List<Behavior> _behaviors;
  GameComponent? _comp;
  int _indexCurrent = 0;
  bool _isRunning = true;
  final bool debug;

  /// Whether the behavior list is currently being processed.
  bool get isRunning => _isRunning;

  /// The `id` of the current behavior (or its index when no `id` is set),
  /// useful to inspect/debug which behavior is active.
  dynamic get currentBehaviorId {
    if (_behaviors.isEmpty) {
      return null;
    }
    return _behaviors[_indexCurrent].id ?? _indexCurrent;
  }

  BehaviorManager({
    required List<Behavior> behaviors,
    this.debug = false,
  }) : _behaviors = behaviors;

  void updateBehaviors(List<Behavior> behaviors) {
    if (_behaviors.length != behaviors.length) {
      _indexCurrent = 0;
    }
    _behaviors = behaviors;
  }

  @override
  void update(double dt) {
    final comp = _comp ??= parent! as GameComponent;
    if (_isRunning && _behaviors.isNotEmpty) {
      final currentAction = _behaviors[_indexCurrent];
      if (currentAction.process(dt, comp, gameRef)) {
        final previousIndex = _indexCurrent;
        if (_indexCurrent < _behaviors.length - 1) {
          _indexCurrent++;
        } else {
          _indexCurrent = 0;
        }
        if (debug && previousIndex != _indexCurrent) {
          debugPrint(
            'Behavior changed: #$previousIndex -> #$_indexCurrent '
            '(${currentAction.id ?? _indexCurrent})',
          );
        }
      }
    }

    super.update(dt);
  }

  void pause() {
    _isRunning = false;
  }

  void resume() {
    _isRunning = true;
  }
}
