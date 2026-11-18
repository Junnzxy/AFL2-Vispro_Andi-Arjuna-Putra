import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import 'todo_state.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository repository;

  TodoCubit({required this.repository}) : super(const TodoInitial());

  Future<void> loadTodos() async {
    emit(const TodoLoading());
    try {
      final todos = await repository.getTodos();
      if (isClosed) return;

      if (todos.isEmpty) {
        emit(const TodoEmpty());
      } else {
        emit(TodoLoaded(todos));
      }
    } catch (_) {
      if (isClosed) return;
      emit(const TodoError('Gagal memuat daftar tugas dari penyimpanan.'));
    }
  }

  Future<void> addTodo(String title, {String? id}) async {
    if (title.trim().isEmpty) {
      emit(const TodoError('Judul tugas tidak boleh kosong.'));
      return;
    }

    final currentTodos = switch (state) {
      TodoLoaded(:final todos) => todos,
      _ => <Todo>[],
    };

    final newTodo = Todo(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim(),
    );

    try {
      await repository.addTodo(newTodo);
      if (isClosed) return;
      emit(TodoLoaded([...currentTodos, newTodo]));
    } catch (_) {
      if (isClosed) return;
      emit(const TodoError('Gagal menyimpan data ke perangkat.'));
    }
  }

  Future<void> toggleTodo(String id) async {
    final currentTodos = switch (state) {
      TodoLoaded(:final todos) => todos,
      _ => <Todo>[],
    };

    final index = currentTodos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final targetTodo = currentTodos[index];
    final updatedTodo = targetTodo.copyWith(isCompleted: !targetTodo.isCompleted);

    try {
      await repository.updateTodo(updatedTodo);
      if (isClosed) return;

      final updatedList = List<Todo>.from(currentTodos);
      updatedList[index] = updatedTodo;
      emit(TodoLoaded(updatedList));
    } catch (_) {
      if (isClosed) return;
      emit(const TodoError('Gagal memperbarui status tugas.'));
    }
  }

  Future<void> deleteTodo(String id) async {
    final currentTodos = switch (state) {
      TodoLoaded(:final todos) => todos,
      _ => <Todo>[],
    };

    try {
      await repository.deleteTodo(id);
      if (isClosed) return;

      final remainingTodos = currentTodos.where((todo) => todo.id != id).toList();
      if (remainingTodos.isEmpty) {
        emit(const TodoEmpty());
      } else {
        emit(TodoLoaded(remainingTodos));
      }
    } catch (_) {
      if (isClosed) return;
      emit(const TodoError('Gagal menghapus tugas dari perangkat.'));
    }
  }
}

