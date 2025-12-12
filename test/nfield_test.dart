import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nstater/nstater.dart';

void main() {
  group('NField', () {
    testWidgets('renders initial value', (tester) async {
      final nvar = NVar<int>(42);

      await tester.pumpWidget(MaterialApp(home: NField<int>(data: nvar, builder: (value) => Text('$value'))));

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('rebuilds when value changes', (tester) async {
      final nvar = NVar<int>(0);

      await tester.pumpWidget(MaterialApp(home: NField<int>(data: nvar, builder: (value) => Text('$value'))));

      expect(find.text('0'), findsOneWidget);

      nvar.value = 42;
      await tester.pump();

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('does not rebuild when value is the same', (tester) async {
      final nvar = NVar<int>(42);
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: NField<int>(
            data: nvar,
            builder: (value) {
              buildCount++;
              return Text('$value');
            },
          ),
        ),
      );

      buildCount = 0; // Reset after initial build
      nvar.value = 42;
      await tester.pump();

      expect(buildCount, 0);
    });

    testWidgets('shouldRebuild controls rebuild behavior', (tester) async {
      final nvar = NVar<String>('Hello');
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: NField<String>(
            data: nvar,
            shouldRebuild: (prev, curr) => prev.length != curr.length,
            builder: (value) {
              buildCount++;
              return Text(value);
            },
          ),
        ),
      );

      buildCount = 0; // Reset after initial build

      // Same length, should not rebuild
      nvar.value = 'World';
      await tester.pump();
      expect(buildCount, 0);

      // Different length, should rebuild
      nvar.value = 'Hi';
      await tester.pump();
      expect(buildCount, 1);
    });

    testWidgets('unsubscribes on unmount', (tester) async {
      final nvar = NVar<int>(0);
      int buildCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: NField<int>(
            data: nvar,
            builder: (value) {
              buildCount++;
              return Text('$value');
            },
          ),
        ),
      );

      buildCount = 0;

      // Remove widget
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Change value should not trigger build
      nvar.value = 42;
      await tester.pump();

      expect(buildCount, 0);
    });

    testWidgets('updates subscription when NVar changes', (tester) async {
      final nvar1 = NVar<int>(1);
      final nvar2 = NVar<int>(2);
      final currentNVar = ValueNotifier<NVar<int>>(nvar1);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<NVar<int>>(
            valueListenable: currentNVar,
            builder: (context, nvar, _) => NField<int>(data: nvar, builder: (value) => Text('$value')),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget);

      // Switch to nvar2
      currentNVar.value = nvar2;
      await tester.pump();

      expect(find.text('2'), findsOneWidget);

      // Update nvar1 should not affect widget
      nvar1.value = 10;
      await tester.pump();
      expect(find.text('2'), findsOneWidget);

      // Update nvar2 should affect widget
      nvar2.value = 20;
      await tester.pump();
      expect(find.text('20'), findsOneWidget);
    });
  });
}
