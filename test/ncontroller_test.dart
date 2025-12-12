import 'package:flutter_test/flutter_test.dart';
import 'package:nstater/nstater.dart';

class TestController extends NController<TestController> {
  int count = 0;
  bool onInitCalled = false;
  bool onReadyCalled = false;
  bool beforeMountCalled = false;

  void increment() {
    count++;
    update();
  }

  void incrementSilently() {
    count++;
  }

  void incrementWithSetAndUpdate() {
    setAndUpdate(() => count++);
  }

  @override
  void beforeMount() {
    super.beforeMount();
    beforeMountCalled = true;
  }

  @override
  void onInit() {
    super.onInit();
    onInitCalled = true;
  }

  @override
  void onReady() {
    super.onReady();
    onReadyCalled = true;
  }

  void callUpdate() => update();
}

void main() {
  group('NController', () {
    test('addListener and update notifies listeners', () {
      final controller = TestController();
      int callCount = 0;

      controller.addListener(() => callCount++);
      controller.callUpdate();

      expect(callCount, 1);
    });

    test('does not add duplicate listeners', () {
      final controller = TestController();
      int callCount = 0;
      void listener() => callCount++;

      controller.addListener(listener);
      controller.addListener(listener);
      controller.callUpdate();

      expect(callCount, 1);
    });

    test('removeListener stops notifications', () {
      final controller = TestController();
      int callCount = 0;
      void listener() => callCount++;

      controller.addListener(listener);
      controller.removeListener(listener);
      controller.callUpdate();

      expect(callCount, 0);
    });

    test('setAndUpdate mutates state and notifies', () {
      final controller = TestController();
      int callCount = 0;

      controller.addListener(() => callCount++);
      controller.incrementWithSetAndUpdate();

      expect(controller.count, 1);
      expect(callCount, 1);
    });

    test('update notifies multiple listeners', () {
      final controller = TestController();
      int callCount1 = 0;
      int callCount2 = 0;

      controller.addListener(() => callCount1++);
      controller.addListener(() => callCount2++);
      controller.callUpdate();

      expect(callCount1, 1);
      expect(callCount2, 1);
    });

    test('handles errors in listeners gracefully', () {
      final controller = TestController();
      int safeCallCount = 0;

      controller.addListener(() => throw Exception('Test error'));
      controller.addListener(() => safeCallCount++);
      controller.callUpdate();

      expect(safeCallCount, 1);
    });

    test('cannot update after dispose', () {
      final controller = TestController();
      int callCount = 0;

      controller.addListener(() => callCount++);
      controller.dispose();
      controller.callUpdate();

      expect(callCount, 0);
    });

    test('cannot setAndUpdate after dispose', () {
      final controller = TestController();
      int callCount = 0;

      controller.addListener(() => callCount++);
      controller.dispose();
      controller.incrementWithSetAndUpdate();

      expect(controller.count, 0);
      expect(callCount, 0);
    });

    test('dispose clears all listeners', () {
      final controller = TestController();
      int callCount = 0;

      controller.addListener(() => callCount++);
      controller.dispose();
      controller.callUpdate();

      expect(callCount, 0);
    });

    test('lifecycle methods can be overridden', () {
      final controller = TestController();

      controller.beforeMount();
      controller.onInit();
      controller.onReady();

      expect(controller.beforeMountCalled, true);
      expect(controller.onInitCalled, true);
      expect(controller.onReadyCalled, true);
    });

    test('warns when disposing already disposed controller', () {
      final controller = TestController();

      controller.dispose();
      // Should print warning but not throw
      expect(() => controller.dispose(), returnsNormally);
    });
  });
}
