import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:to_do_list/domain/entities/todo.dart';
import 'package:to_do_list/domain/repositories/todo_repository.dart';
import 'package:to_do_list/presentation/cubit/todo_cubit.dart';
import 'package:to_do_list/presentation/cubit/todo_state.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

class FakeTodo extends Fake implements Todo {}

void main() {
  late MockTodoRepository mockRepository;
  late TodoCubit todoCubit;

  const tTodo1 = Todo(id: '1', title: 'Belajar Flutter MVVM', isCompleted: false);
  const tTodo2 = Todo(id: '2', title: 'Membuat Unit Test', isCompleted: false);

  setUpAll(() {
    registerFallbackValue(FakeTodo());
  });

  setUp(() {
    mockRepository = MockTodoRepository();
    todoCubit = TodoCubit(repository: mockRepository);
  });

  tearDown(() {
    todoCubit.close();
  });

  group('TodoCubit Comprehensive Scenario Tests', () {
    // 1. Initial state verification
    test('1. Initial state should be TodoInitial', () {
      expect(todoCubit.state, const TodoInitial());
    });

    // 2. Loading tasks when storage is empty emits TodoLoading then TodoEmpty
    blocTest<TodoCubit, TodoState>(
      '2. Loading tasks when storage is empty emits [TodoLoading, TodoEmpty]',
      build: () {
        when(() => mockRepository.getTodos()).thenAnswer((_) async => []);
        return todoCubit;
      },
      act: (cubit) => cubit.loadTodos(),
      expect: () => [
        const TodoLoading(),
        const TodoEmpty(),
      ],
      verify: (_) {
        verify(() => mockRepository.getTodos()).called(1);
      },
    );

    // 3. Loading tasks when storage has data emits TodoLoading then TodoLoaded
    blocTest<TodoCubit, TodoState>(
      '3. Loading tasks when storage has data emits [TodoLoading, TodoLoaded]',
      build: () {
        when(() => mockRepository.getTodos()).thenAnswer((_) async => [tTodo1, tTodo2]);
        return todoCubit;
      },
      act: (cubit) => cubit.loadTodos(),
      expect: () => [
        const TodoLoading(),
        const TodoLoaded([tTodo1, tTodo2]),
      ],
      verify: (_) {
        verify(() => mockRepository.getTodos()).called(1);
      },
    );

    // 4. Loading tasks failure emits TodoLoading then TodoError with Indonesian message
    blocTest<TodoCubit, TodoState>(
      '4. Loading tasks failure emits [TodoLoading, TodoError] with Indonesian message',
      build: () {
        when(() => mockRepository.getTodos()).thenThrow(Exception('Database error'));
        return todoCubit;
      },
      act: (cubit) => cubit.loadTodos(),
      expect: () => [
        const TodoLoading(),
        const TodoError('Gagal memuat daftar tugas dari penyimpanan.'),
      ],
      verify: (_) {
        verify(() => mockRepository.getTodos()).called(1);
      },
    );

    // 5. Adding a valid task updates state to TodoLoaded and persists data
    blocTest<TodoCubit, TodoState>(
      '5. Adding a valid task updates state to TodoLoaded and persists data',
      build: () {
        when(() => mockRepository.addTodo(any())).thenAnswer((_) async {});
        return todoCubit;
      },
      act: (cubit) => cubit.addTodo('Tugas Baru', id: '1'),
      expect: () => [
        const TodoLoaded([Todo(id: '1', title: 'Tugas Baru', isCompleted: false)]),
      ],
      verify: (_) {
        verify(() => mockRepository.addTodo(const Todo(id: '1', title: 'Tugas Baru', isCompleted: false))).called(1);
      },
    );

    // 6. Adding an empty or whitespace-only task emits TodoError without corrupting current list
    blocTest<TodoCubit, TodoState>(
      '6. Adding an empty or whitespace-only task emits TodoError without corrupting current list',
      build: () => todoCubit,
      seed: () => const TodoLoaded([tTodo1]),
      act: (cubit) => cubit.addTodo('   '),
      expect: () => [
        const TodoError('Judul tugas tidak boleh kosong.'),
      ],
      verify: (_) {
        verifyNever(() => mockRepository.addTodo(any()));
      },
    );

    // 7. Adding a task when storage throws an exception emits TodoError
    blocTest<TodoCubit, TodoState>(
      '7. Adding a task when storage throws an exception emits TodoError',
      build: () {
        when(() => mockRepository.addTodo(any())).thenThrow(Exception('Disk full'));
        return todoCubit;
      },
      act: (cubit) => cubit.addTodo('Tugas Baru', id: '1'),
      expect: () => [
        const TodoError('Gagal menyimpan data ke perangkat.'),
      ],
      verify: (_) {
        verify(() => mockRepository.addTodo(any())).called(1);
      },
    );

    // 8. Toggling a task completion status updates the specific item in TodoLoaded
    blocTest<TodoCubit, TodoState>(
      '8. Toggling a task completion status updates the specific item in TodoLoaded',
      build: () {
        when(() => mockRepository.updateTodo(any())).thenAnswer((_) async {});
        return todoCubit;
      },
      seed: () => const TodoLoaded([tTodo1, tTodo2]),
      act: (cubit) => cubit.toggleTodo(tTodo1.id),
      expect: () => [
        TodoLoaded([tTodo1.copyWith(isCompleted: true), tTodo2]),
      ],
      verify: (_) {
        verify(() => mockRepository.updateTodo(tTodo1.copyWith(isCompleted: true))).called(1);
      },
    );

    // 9. Deleting one task from multiple tasks keeps remaining tasks in TodoLoaded
    blocTest<TodoCubit, TodoState>(
      '9. Deleting one task from multiple tasks keeps remaining tasks in TodoLoaded',
      build: () {
        when(() => mockRepository.deleteTodo(any())).thenAnswer((_) async {});
        return todoCubit;
      },
      seed: () => const TodoLoaded([tTodo1, tTodo2]),
      act: (cubit) => cubit.deleteTodo(tTodo1.id),
      expect: () => [
        const TodoLoaded([tTodo2]),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteTodo(tTodo1.id)).called(1);
      },
    );

    // 10. Deleting the last remaining task transitions state cleanly from TodoLoaded to TodoEmpty
    blocTest<TodoCubit, TodoState>(
      '10. Deleting the last remaining task transitions state cleanly from TodoLoaded to TodoEmpty',
      build: () {
        when(() => mockRepository.deleteTodo(any())).thenAnswer((_) async {});
        return todoCubit;
      },
      seed: () => const TodoLoaded([tTodo1]),
      act: (cubit) => cubit.deleteTodo(tTodo1.id),
      expect: () => [
        const TodoEmpty(),
      ],
      verify: (_) {
        verify(() => mockRepository.deleteTodo(tTodo1.id)).called(1);
      },
    );

    // 11. Rapid consecutive actions / Cubit closure safety (isClosed guard verification)
    test('11. Rapid consecutive actions / Cubit closure safety (isClosed guard verification)', () async {
      when(() => mockRepository.getTodos()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        return [tTodo1];
      });

      // Trigger asynchronous loading
      final loadFuture = todoCubit.loadTodos();

      // Immediately close the Cubit while the async call is in-flight
      await todoCubit.close();

      // Await completion of repository call
      await loadFuture;

      // Verify that Cubit is closed and no state transition occurred after close
      expect(todoCubit.isClosed, isTrue);
    });
  });
}

