import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IntervalTick', () {
    test('fires after the interval elapses', () {
      final tick = IntervalTick(100); // 100ms
      expect(tick.update(0.05), isFalse);
      expect(tick.update(0.049), isFalse);
      expect(tick.update(0.01), isTrue,
          reason: '0.05+0.049+0.01 = 0.109 >= 0.1');
    });

    test('does not fire again until time accumulates again', () {
      final tick = IntervalTick(100);
      tick.update(0.1);
      expect(tick.update(0.05), isFalse, reason: 'counter reset after tick');
      expect(tick.update(0.05), isTrue);
    });

    test('tickFirstUpdate fires on the first update', () {
      final tick = IntervalTick(100, tickFirstUpdate: true);
      expect(tick.update(0.001), isTrue);
      expect(tick.update(0.05), isFalse);
      expect(tick.update(0.05), isTrue);
    });

    test('onTick callback is invoked when firing', () {
      var calls = 0;
      final tick = IntervalTick(100, onTick: () => calls++);
      tick.update(0.1);
      expect(calls, 1);
      tick.update(0.1);
      expect(calls, 2);
    });

    test('reset() clears accumulated time', () {
      final tick = IntervalTick(100);
      tick.update(0.09);
      tick.reset();
      expect(tick.update(0.09), isFalse, reason: 'time cleared by reset');
      expect(tick.update(0.02), isTrue);
    });

    test('pause() and play() control the ticking', () {
      final tick = IntervalTick(100);
      tick.pause();
      expect(tick.running, isFalse);
      tick.update(5.0);
      expect(tick.update(0.01), isFalse, reason: 'paused ticks never fire');

      tick.play();
      expect(tick.running, isTrue);
      expect(tick.update(0.1), isTrue);
    });

    test('tick() forces the interval to complete on next update', () {
      final tick = IntervalTick(100);
      tick.tick();
      expect(tick.update(0.001), isTrue);
    });

    test('updateInterval() changes the period', () {
      final tick = IntervalTick(1000);
      tick.updateInterval(100);
      expect(tick.update(0.1), isTrue);
    });
  });
}
