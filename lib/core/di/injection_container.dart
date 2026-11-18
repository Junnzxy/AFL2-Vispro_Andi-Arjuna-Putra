import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unused_import
import '../../data/repositories/in_memory_todo_repository.dart';
import '../../data/repositories/local_todo_repository.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../presentation/cubit/todo_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  if (sl.isRegistered<TodoRepository>()) {
    return;
  }

  // ---------------------------------------------------------------------------
  // External Dependencies
  // ---------------------------------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ---------------------------------------------------------------------------
  // Repository Layer (Data / Domain)
  // ---------------------------------------------------------------------------
  // ONE-LINE SOURCE SWAP:
  // Uncomment the InMemoryTodoRepository line and comment out LocalTodoRepository
  // to switch the entire application storage to volatile RAM-only mode.
  sl.registerLazySingleton<TodoRepository>(() => LocalTodoRepository(sharedPreferences: sl()));
  // sl.registerLazySingleton<TodoRepository>(() => InMemoryTodoRepository());

  // ---------------------------------------------------------------------------
  // Presentation Layer (Cubit)
  // ---------------------------------------------------------------------------
  sl.registerFactory<TodoCubit>(() => TodoCubit(repository: sl()));
}
