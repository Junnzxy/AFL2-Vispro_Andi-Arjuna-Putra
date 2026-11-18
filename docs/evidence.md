# Submission Evidence & Demonstration Report

## 1. Persistence Verification Evidence

### Procedure
1. Launch application on target device / emulator.
2. Add multiple tasks (e.g., "Selesaikan Laporan AFL-2", "Review Clean Architecture", "Siapkan Unit Test").
3. Toggle one task to completed state.
4. Force kill / terminate the application process (`kill` from app switcher or terminal).
5. Relaunch application (cold start).
6. Verify all tasks and their completion statuses are immediately restored from `shared_preferences`.

### Step-by-Step Execution Log & Screenshot Placeholders

| Step | Action Taken | Expected State | Screenshot Placeholder |
|---|---|---|---|
| **Step 1: Write Data** | Added 3 tasks: "Selesaikan Laporan AFL-2", "Review Clean Architecture", "Siapkan Unit Test". Marked first task completed. | List displays 3 items; first item crossed out. | `[ATTACH SCREENSHOT: Data Written & Marked]` |
| **Step 2: Terminate App** | Swipe away from recent apps / executed taskkill to force kill process. | Process destroyed; memory freed. | `[ATTACH SCREENSHOT: Process Killed / App Switcher]` |
| **Step 3: Cold Relaunch** | Tap app icon to launch from cold start. | State transitions: `TodoInitial` -> `TodoLoading` -> `TodoLoaded`. All 3 tasks restored intact. | `[ATTACH SCREENSHOT: Reopened App with Data Intact]` |

---

## 2. One-Line Source-Swap Evidence

### Implementation Snippet (`lib/core/di/injection_container.dart`)
```dart
// Location: lib/core/di/injection_container.dart

// ---------------------------------------------------------------------------
// ONE-LINE SOURCE SWAP:
// Uncomment the InMemoryTodoRepository line and comment out LocalTodoRepository
// to switch the entire application storage to volatile RAM-only mode.
// ---------------------------------------------------------------------------
sl.registerLazySingleton<TodoRepository>(() => LocalTodoRepository(sharedPreferences: sl()));
// sl.registerLazySingleton<TodoRepository>(() => InMemoryTodoRepository());
```

### Verification & Comparison Table

| Feature / Behavior | Persistent (`LocalTodoRepository`) | Volatile RAM (`InMemoryTodoRepository`) |
|---|---|---|
| **Backing Storage** | `shared_preferences` (Disk JSON) | Dart Heap `List<Todo>` (RAM only) |
| **Cold Restart** | Tasks persist across app restarts | Tasks reset to empty (`TodoEmpty`) upon restart |
| **Code Changes Required** | 0 lines modified in Presentation / Domain | Exactly 1 commented line toggled in `injection_container.dart` |
| **Visual Evidence** | `[ATTACH SCREENSHOT: Data survives restart]` | `[ATTACH SCREENSHOT: Data resets after restart]` |

---

## 3. Mentoring & Architectural Review Record

| Date / Session | Question / Discussion Topic | Mentor / Architectural Feedback | Actions Taken & Code Revisions |
|---|---|---|---|
| **Session 1** | How should we structure the repository contract to avoid leaking data source details into the UI? | Keep repository interface in `domain/` pure abstract Dart with no imports from Flutter or 3rd-party storage packages. | Created `domain/repositories/todo_repository.dart` using pure Dart `Todo` entity and `Future<T>`. |
| **Session 2** | Is it acceptable to use `StatefulWidget` for handling dialog text input? | Zero `setState` rule is strict. Use pure `StatelessWidget` and properly dispose `TextEditingController` via `.then((_) => controller.dispose())` on dialog pop. | Updated `todo_page.dart` to pure `StatelessWidget` with lifecycle-safe dialog disposal and zero memory leaks. |
| **Session 3** | How do we guarantee Cubit does not emit states after being closed during rapid user interactions? | Guard every asynchronous operation with `if (isClosed) return;` immediately following every `await`. | Enforced `if (isClosed) return;` across `loadTodos()`, `addTodo()`, `toggleTodo()`, and `deleteTodo()` in `todo_cubit.dart`. |
| **Session 4** | What is the best practice for exhaustive UI state rendering in Dart 3? | Use Dart 3 exhaustive `switch` expressions on `sealed class TodoState` to guarantee compile-time exhaustiveness without blank screens. | Implemented exhaustive pattern matching in `TodoPage` covering `TodoInitial`, `TodoLoading`, `TodoEmpty`, `TodoLoaded`, and `TodoError`. |

