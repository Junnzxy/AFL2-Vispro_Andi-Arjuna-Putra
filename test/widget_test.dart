import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:to_do_list/domain/entities/todo.dart';
import 'package:to_do_list/presentation/widgets/todo_item_tile.dart';

void main() {
  testWidgets('TodoItemTile renders task title and responds to callbacks', (tester) async {
    bool toggled = false;
    bool deleted = false;

    const todo = Todo(
      id: '1',
      title: 'Tugas Uji Widget',
      isCompleted: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TodoItemTile(
            todo: todo,
            onToggle: () => toggled = true,
            onDelete: () => deleted = true,
          ),
        ),
      ),
    );

    expect(find.text('Tugas Uji Widget'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    expect(toggled, isTrue);

    await tester.tap(find.byIcon(Icons.delete_outline_rounded));
    expect(deleted, isTrue);
  });
}
