import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';

class InMemoryTodoRepository implements TodoRepository {
  final List<Todo> _todos = [];

  @override
  Future<List<Todo>> getTodos() async {
    return List<Todo>.unmodifiable(_todos);
  }

  @override
  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((element) => element.id == todo.id);
    if (index != -1) {
      _todos[index] = todo;
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((element) => element.id == id);
  }
}

