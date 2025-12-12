import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nstater/nstater.dart';

class CounterController extends NController<CounterController> {
  int count = 0;
  bool beforeMountCalled = false;
  bool onInitCalled = false;
  bool onReadyCalled = false;
  bool disposed = false;

  void increment() {
    count++;
    update();
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

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

void main() {
  group('NState', () {
    testWidgets('creates and provides controller', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NState<CounterController>(
            create: () => CounterController(),
            builder: (controller) => Text('${controller.count}'),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('calls lifecycle methods in correct order', (tester) async {
      CounterController? controller;

      await tester.pumpWidget(
        MaterialApp(
          home: NState<CounterController>(
            create: () {
              controller = CounterController();
              return controller!;
            },
            builder: (c) => const SizedBox(),
          ),
        ),
      );

      expect(controller!.beforeMountCalled, true);
      expect(controller!.onInitCalled, true);

      // Wait for microtask (onReady)
      await tester.pumpAndSettle();
      expect(controller!.onReadyCalled, true);
    });

    testWidgets('rebuilds when controller calls update', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NState<CounterController>(
            create: () => CounterController(),
            builder:
                (controller) => Column(
                  children: [
                    Text('${controller.count}'),
                    ElevatedButton(onPressed: controller.increment, child: const Text('Increment')),
                  ],
                ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.text('Increment'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('disposes controller on unmount', (tester) async {
      CounterController? controller;

      await tester.pumpWidget(
        MaterialApp(
          home: NState<CounterController>(
            create: () {
              controller = CounterController();
              return controller!;
            },
            builder: (c) => const SizedBox(),
          ),
        ),
      );

      expect(controller!.disposed, false);

      // Remove widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      expect(controller!.disposed, true);
    });

    testWidgets('controller does not rebuild after dispose', (tester) async {
      CounterController? controller;
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: NState<CounterController>(
            create: () {
              controller = CounterController();
              return controller!;
            },
            builder: (c) {
              buildCount++;
              return Text('${c.count}');
            },
          ),
        ),
      );

      buildCount = 0; // Reset

      // Remove widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Try to update disposed controller
      controller!.increment();
      await tester.pump();

      expect(buildCount, 0);
    });
  });
}
