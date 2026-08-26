import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void main() {
  late MovableComponent comp;
  late FakeBonfireGame game;

  setUp(() {
    comp = MovableComponent();
    game = FakeBonfireGame();
    comp.gameRef = game;
  });

  BehaviorManager mountManager(List<Behavior> behaviors) {
    final manager = BehaviorManager(behaviors: behaviors);
    comp.add(manager);
    return manager;
  }

  group('BehaviorManager', () {
    test('advances to the next behavior when the current one returns true', () {
      var firstRuns = 0;
      var secondRuns = 0;
      final manager = mountManager([
        BCustom(
          behavior: (_, __, ___) {
            firstRuns++;
            return true; // finished
          },
        ),
        BCustom(
          behavior: (_, __, ___) {
            secondRuns++;
            return false; // keeps running
          },
        ),
      ]);

      manager.update(0.016);
      manager.update(0.016);
      manager.update(0.016);

      expect(firstRuns, 1); // ran once, then advanced
      expect(secondRuns, 2); // keeps running from then on
    });

    test('stays on the current behavior while it returns false', () {
      var runs = 0;
      final manager = mountManager([
        BCustom(
          behavior: (_, __, ___) {
            runs++;
            return false;
          },
        ),
      ]);

      manager.update(0.016);
      manager.update(0.016);

      expect(runs, 2);
    });

    test('loops back to the first behavior at the end of the list', () {
      final order = <String>[];
      final manager = mountManager([
        BCustom(
          behavior: (_, __, ___) {
            order.add('a');
            return true;
          },
        ),
        BCustom(
          behavior: (_, __, ___) {
            order.add('b');
            return true;
          },
        ),
      ]);

      manager.update(0.016);
      manager.update(0.016);
      manager.update(0.016);

      expect(order, ['a', 'b', 'a']);
    });

    test('currentBehaviorId exposes the id/index of the active behavior', () {
      final manager = mountManager([
        BCustom(id: 'patrol', behavior: (_, __, ___) => true),
        BCustom(id: 'chase', behavior: (_, __, ___) => false),
      ]);

      expect(manager.currentBehaviorId, 'patrol');
      manager.update(0.016);
      expect(manager.currentBehaviorId, 'chase');
    });

    test('pause and resume control the execution', () {
      var runs = 0;
      final manager = mountManager([
        BCustom(
          behavior: (_, __, ___) {
            runs++;
            return true;
          },
        ),
      ]);

      manager.pause();
      manager.update(0.016);
      expect(runs, 0);
      expect(manager.isRunning, false);

      manager.resume();
      manager.update(0.016);
      expect(runs, 1);
    });

    test('updateBehaviors replaces the list at runtime', () {
      var oldRuns = 0;
      var newRuns = 0;
      final manager = mountManager([
        BCustom(
          behavior: (_, __, ___) {
            oldRuns++;
            return true;
          },
        ),
      ]);
      manager.update(0.016);
      expect(oldRuns, 1);

      manager.updateBehaviors([
        BCustom(
          behavior: (_, __, ___) {
            newRuns++;
            return true;
          },
        ),
      ]);
      manager.update(0.016);

      expect(oldRuns, 1);
      expect(newRuns, 1);
    });
  });

  group('BCondition', () {
    test('runs doBehavior when the condition is true', () {
      var ran = 0;
      final b = BCondition(
        condition: (_, __, ___) => true,
        doBehavior: BAction(action: (_, __, ___) => ran++),
      );

      final done = b.process(0.016, comp, game);
      expect(ran, 1);
      expect(done, false); // BAction keeps running
    });

    test('runs doElseBehavior when the condition is false', () {
      var elseRan = 0;
      final b = BCondition(
        condition: (_, __, ___) => false,
        doBehavior: BAction(action: (_, __, ___) {}),
        doElseBehavior: BAction(action: (_, __, ___) => elseRan++),
      );

      b.process(0.016, comp, game);
      expect(elseRan, 1);
    });

    test('returns true (finished) when condition is false and no else', () {
      final b = BCondition(
        condition: (_, __, ___) => false,
        doBehavior: BAction(action: (_, __, ___) {}),
      );

      expect(b.process(0.016, comp, game), true);
    });
  });

  group('BInterval', () {
    test('only runs the inner behavior when the interval ticks', () {
      var runs = 0;
      final b = BInterval(
        interval: 100,
        doBehavior: BAction(action: (_, __, ___) => runs++),
      );

      // 60ms: not yet
      b.process(0.06, comp, game);
      expect(runs, 0);

      // +60ms = 120ms: ticks
      b.process(0.06, comp, game);
      expect(runs, 1);
    });
  });

  group('BList (sequence)', () {
    test('runs children in order, one per completion', () {
      final order = <String>[];
      final b = BList(
        behaviors: [
          BCustom(
            behavior: (_, __, ___) {
              order.add('first');
              return true;
            },
          ),
          BCustom(
            behavior: (_, __, ___) {
              order.add('second');
              return true;
            },
          ),
        ],
      );

      b.process(0.016, comp, game);
      expect(order, ['first']);
      expect(b.process(0.016, comp, game), true); // finished
      expect(order, ['first', 'second']);
    });
  });

  group('BSelector', () {
    test('picks the first child that is active', () {
      var firstActiveRuns = 0;
      var secondRuns = 0;
      final b = BSelector(
        behaviors: [
          // finished -> skip to next
          BCustom(behavior: (_, __, ___) => true),
          // active -> wins
          BCustom(
            behavior: (_, __, ___) {
              firstActiveRuns++;
              return false;
            },
          ),
          BCustom(
            behavior: (_, __, ___) {
              secondRuns++;
              return true;
            },
          ),
        ],
      );

      b.process(0.016, comp, game);
      expect(firstActiveRuns, 1);
      expect(secondRuns, 0);
      expect(b.process(0.016, comp, game), false); // still active
    });

    test('returns true when no child is active', () {
      final b = BSelector(
        behaviors: [
          BCustom(behavior: (_, __, ___) => true),
          BCustom(behavior: (_, __, ___) => true),
        ],
      );

      expect(b.process(0.016, comp, game), true);
    });
  });

  group('BParallel', () {
    test('runs all children every frame', () {
      var a = 0;
      var bRuns = 0;
      final b = BParallel(
        behaviors: [
          BCustom(
            behavior: (_, __, ___) {
              a++;
              return false;
            },
          ),
          BCustom(
            behavior: (_, __, ___) {
              bRuns++;
              return true;
            },
          ),
        ],
      );

      expect(b.process(0.016, comp, game), false); // still running
      expect(a, 1);
      expect(bRuns, 1);
    });

    test('returns true only when all children are finished', () {
      final b = BParallel(
        behaviors: [
          BCustom(behavior: (_, __, ___) => true),
          BCustom(behavior: (_, __, ___) => true),
        ],
      );

      expect(b.process(0.016, comp, game), true);
    });
  });

  group('BOnce', () {
    test('runs the action only once', () {
      var runs = 0;
      final b = BOnce(action: (_, __, ___) => runs++);

      expect(b.process(0.016, comp, game), true);
      expect(b.process(0.016, comp, game), true);
      expect(runs, 1);
    });
  });
}
