import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nstater/nstater.dart';

class TodoController extends NController<TodoController> {
  final todos = NVar<List<String>>([]);

  void addTodo(String todo) {
    todos.value = [...todos.value, todo];
  }

  void removeTodo(int index) {
    final newList = List<String>.from(todos.value);
    newList.removeAt(index);
    todos.value = newList;
  }

  @override
  void dispose() {
    todos.dispose();
    super.dispose();
  }
}

void main() {
  group('NStater Integration Tests', () {
    testWidgets('complete todo app workflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NState<TodoController>(
              create: () => TodoController(),
              builder:
                  (controller) => Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => controller.addTodo('Task ${controller.todos.value.length + 1}'),
                        child: const Text('Add'),
                      ),
                      NField<List<String>>(data: controller.todos, builder: (todos) => Text('Count: ${todos.length}')),
                    ],
                  ),
            ),
          ),
        ),
      );

      expect(find.text('Count: 0'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(find.text('Count: 1'), findsOneWidget);

      await tester.tap(find.text('Add'));
      await tester.pump();
      expect(find.text('Count: 2'), findsOneWidget);
    });
  });
}
