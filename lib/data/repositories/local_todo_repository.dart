import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../models/todo_model.dart';

class LocalTodoRepository implements TodoRepository {
  static const String todosKey = 'CACHED_TODOS_KEY';
  final SharedPreferences sharedPreferences;

  LocalTodoRepository({required this.sharedPreferences});

  @override
  Future<List<Todo>> getTodos() async {
    final jsonString = sharedPreferences.getString(todosKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    final List<dynamic> decodedList = jsonDecode(jsonString) as List<dynamic>;
    return decodedList
        .map((item) => TodoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addTodo(Todo todo) async {
    final todos = await getTodos();
    final updatedList = List<Todo>.from(todos)..add(todo);
    await _saveTodos(updatedList);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    final todos = await getTodos();
    final updatedList = todos.map((item) {
      return item.id == todo.id ? todo : item;
    }).toList();
    await _saveTodos(updatedList);
  }

  @override
  Future<void> deleteTodo(String id) async {
    final todos = await getTodos();
    final updatedList = todos.where((item) => item.id != id).toList();
    await _saveTodos(updatedList);
  }

  Future<void> _saveTodos(List<Todo> todos) async {
    final models = todos.map((e) => TodoModel.fromEntity(e).toJson()).toList();
    final jsonString = jsonEncode(models);
    await sharedPreferences.setString(todosKey, jsonString);
  }
}

