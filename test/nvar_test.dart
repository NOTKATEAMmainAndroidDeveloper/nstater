import 'package:flutter_test/flutter_test.dart';
import 'package:nstater/nstater.dart';

void main() {
  group('NVar', () {
    test('initializes with correct value', () {
      final nVar = NVar<int>(42);
      expect(nVar.value, 42);
    });

    test('notifies listeners when value changes', () {
      final nVar = NVar<int>(0);
      int callCount = 0;
      int? receivedValue;

      nVar.addListener((newValue) {
        callCount++;
        receivedValue = newValue;
      });

      nVar.value = 42;

      expect(callCount, 1);
      expect(receivedValue, 42);
    });

    test('does not notify listeners when value is the same', () {
      final nVar = NVar<int>(42);
      int callCount = 0;

      nVar.addListener((newValue) => callCount++);
      nVar.value = 42;

      expect(callCount, 0);
    });

    test('notifies multiple listeners', () {
      final nVar = NVar<int>(0);
      int callCount1 = 0;
      int callCount2 = 0;

      nVar.addListener((_) => callCount1++);
      nVar.addListener((_) => callCount2++);

      nVar.value = 1;

      expect(callCount1, 1);
      expect(callCount2, 1);
    });

    test('does not add duplicate listeners', () {
      final nVar = NVar<int>(0);
      int callCount = 0;
      void listener(int _) => callCount++;

      nVar.addListener(listener);
      nVar.addListener(listener);

      nVar.value = 1;

      expect(callCount, 1);
    });

    test('removes listener correctly', () {
      final nVar = NVar<int>(0);
      int callCount = 0;
      void listener(int _) => callCount++;

      nVar.addListener(listener);
      nVar.removeListener(listener);
      nVar.value = 1;

      expect(callCount, 0);
    });

    test('custom isEqual prevents notification', () {
      final nVar = NVar<List<int>>([1, 2, 3], isEqual: (a, b) => a.length == b.length);
      int callCount = 0;

      nVar.addListener((_) => callCount++);
      nVar.value = [4, 5, 6]; // Same length, should not notify

      expect(callCount, 0);
    });

    test('custom isEqual allows notification when condition fails', () {
      final nVar = NVar<List<int>>([1, 2, 3], isEqual: (a, b) => a.length == b.length);
      int callCount = 0;

      nVar.addListener((_) => callCount++);
      nVar.value = [1, 2, 3, 4]; // Different length, should notify

      expect(callCount, 1);
    });

    test('dispose clears all listeners', () {
      final nVar = NVar<int>(0);
      int callCount = 0;

      nVar.addListener((_) => callCount++);
      nVar.dispose();
      nVar.value = 1;

      expect(callCount, 0);
    });

    test('handles errors in listeners gracefully', () {
      final nVar = NVar<int>(0);
      int safeCallCount = 0;

      nVar.addListener((_) => throw Exception('Test error'));
      nVar.addListener((_) => safeCallCount++);

      nVar.value = 1;

      // Second listener should still be called despite first one throwing
      expect(safeCallCount, 1);
    });
  });
}
