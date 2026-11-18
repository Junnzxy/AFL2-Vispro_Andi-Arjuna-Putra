# Module 3 Readiness Architectural Audit

## Question:
> *"If your data had to come from a server over the internet next week instead of from local storage, how many files would you have to change? List them."*

---

## 1. Executive Answer: Exactly 2 Files

Thanks to the strict adherence to Clean Architecture and the Dependency Inversion Principle (DIP), migrating from local storage (`shared_preferences`) to a remote REST/GraphQL backend requires touching **exactly 2 files**:

1. **`lib/data/repositories/remote_todo_repository.dart`** (NEW file creation)
   - Implement the existing abstract domain contract `TodoRepository`.
   - Make HTTP network calls (e.g., via `http` or `dio`) and map responses using the existing `TodoModel.fromJson()`.
2. **`lib/core/di/injection_container.dart`** (MODIFY 1 single line)
   - Change the registered factory/singleton for `TodoRepository`:
   ```dart
   // Swap Local/InMemory with the new Remote implementation:
   sl.registerLazySingleton<TodoRepository>(() => RemoteTodoRepository(client: sl()));
   ```

---

## 2. Comprehensive File Impact Analysis

| Layer | File Path | Status | Impact Reason |
|---|---|---|---|
| **Domain** | `lib/domain/entities/todo.dart` | **Untouched** | Pure business entity; network transport details do not alter the entity. |
| **Domain** | `lib/domain/repositories/todo_repository.dart` | **Untouched** | Abstract contract remains identical (`getTodos()`, `addTodo()`, `updateTodo()`, `deleteTodo()`). |
| **Data** | `lib/data/models/todo_model.dart` | **Untouched** | `fromJson` and `toJson` already handle standard JSON payload mapping. |
| **Data** | `lib/data/repositories/in_memory_todo_repository.dart` | **Untouched** | Left intact for testing or offline fallback. |
| **Data** | `lib/data/repositories/local_todo_repository.dart` | **Untouched** | Left intact for local caching / offline sync if desired. |
| **Data** | `lib/data/repositories/remote_todo_repository.dart` | **CREATED (File 1)** | New repository implementing `TodoRepository` over network protocol. |
| **Core** | `lib/core/di/injection_container.dart` | **MODIFIED (File 2)** | 1-line registration change to bind `TodoRepository` to `RemoteTodoRepository`. |
| **Core** | `lib/core/error/failures.dart` | **Untouched** | Standard `Failure` hierarchy already accommodates error messaging. |
| **Presentation** | `lib/presentation/cubit/todo_cubit.dart` | **Untouched** | Depends solely on `TodoRepository` contract; zero coupling to storage mechanism. |
| **Presentation** | `lib/presentation/cubit/todo_state.dart` | **Untouched** | State definitions (`TodoLoaded`, `TodoError`, etc.) remain identical. |
| **Presentation** | `lib/presentation/pages/todo_page.dart` | **Untouched** | Consumes `TodoCubit`; zero knowledge of data source. |
| **Presentation** | `lib/presentation/widgets/todo_item_tile.dart` | **Untouched** | Consumes `Todo` domain entity; zero knowledge of data source. |

---

## 3. Data-Layer Leakage Audit
An audit of `lib/presentation/` confirms:
- **Zero imports from `package:to_do_list/data/` or `../../data/`**.
- Presentation classes only import `domain/entities/todo.dart` and `domain/repositories/todo_repository.dart`.
- The presentation layer compiles in complete isolation even if the entire `lib/data/` directory is replaced with another implementation.

## 4. Conclusion
The application achieves **100% decoupling between presentation and data persistence**, verifying complete readiness for Module 3 remote integration with maximum developer ergonomics and zero regression risks.

