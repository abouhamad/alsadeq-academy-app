# Al Sadeq Academy App

Flutter client for the eSkooly Pro backend at `https://portal.alsadeq-academy.com`.
Supports Student, Parent and Teacher logins (`role_id` 2, 3, 4).

## First-time setup

This project was hand-authored (no Flutter SDK was available in the scaffolding
environment), so the native `android/`, `ios/`, `web/` platform folders don't
exist yet. From this directory:

```bash
flutter create .        # generates the missing platform folders; leaves lib/ and pubspec.yaml untouched
flutter pub get
```

`pubspec.yaml`'s dependency versions were pinned by hand (no Flutter SDK was
available to run `pub get`/`pub outdated` while scaffolding), so they may be
stale by the time you run this. If `flutter pub get` reports a version
conflict — most likely on `intl`, which Flutter's SDK often pins tightly —
run `flutter pub upgrade --major-versions` or loosen the offending
constraint in `pubspec.yaml`.

### Push notifications (optional but backend-ready)

The Laravel backend already sends FCM pushes with
`data.click_action = "FLUTTER_NOTIFICATION_CLICK"`
(`app/Notifications/FlutterAppNotification.php`). To receive them:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This generates `lib/firebase_options.dart` and the platform config files.
Until you do this, the app runs fine — `main.dart` catches the
`Firebase.initializeApp()` failure and just disables push.

### Run

```bash
flutter run
```

## Architecture

- **State management**: Riverpod (`flutter_riverpod`), no code generation.
- **Routing**: `go_router`, redirect-based auth guard (`core/routing/app_router.dart`).
- **Networking**: `core/network/api_client.dart` — two `Dio` instances (v1 `/api`,
  v2 `/api/v2`), shared auth interceptor, unwraps the backend's
  `{success, data, message}` envelope into `ApiException`s.
- **Auth**: `features/auth` — uses the v2 `AuthenticationController@login` flow.
  Token is stored via `flutter_secure_storage` and replayed as-is in the
  `Authorization` header (the backend already prefixes it with `"Bearer "`).
- **Feature modules** (`features/homework`, `attendance`, `notices`, `routine`,
  `fees`, `exams`): each follows `data/` (models + repository) →
  `presentation/providers` (Riverpod `FutureProvider`) →
  `presentation/screens`.

## Known gaps to verify against the live API

This scaffold was built from reading the Laravel route files and a handful of
controller methods, not from live API responses. Endpoints are wired to the
correct URLs, but a few response shapes are best-effort guesses — each is
flagged with a `// NOTE` or doc comment at the point of use:

- **Attendance** (`features/attendance/data/attendance_repository.dart`): the
  exact query params for `student-attendance-report` / `my-attendance/{id}`
  weren't confirmed from source.
- **Notices** (`features/notices/data/notices_repository.dart`): only
  `student-noticeboard/{id}` was found in routes; parent/teacher currently
  reuse it.
- **Fees** (`features/fees/data/fees_repository.dart`): `search-fees-due`'s
  query param name is a best guess.
- **Exams**: shows the exam *schedule* (`student-exam-schedule/{student_id}`),
  not *results* — the results endpoints need an `exam_id` that isn't
  available without an exam-listing call that wasn't part of the routes
  reviewed.
- **Homework file download**: `HomeworkDetailScreen`'s "Open attachment"
  button is a stub — wire it to `ApiEndpoints.studentHomeworkFileDownload`
  with `url_launcher` (already a dependency) once the file URL shape is
  confirmed.

Model classes (`homework_model.dart`, `attendance_record_model.dart`, etc.)
use tolerant multi-key lookups (e.g. `title` → `homework_title` → `name`) so a
close-but-not-exact guess degrades gracefully instead of crashing — tighten
them once you've inspected a real response (e.g. via the backend's own
Postman collection if one exists, or by logging `response.data` once).

## Adding a new feature module

Copy the shape of `features/notices/` (smallest complete example):
1. `data/models/<x>_model.dart` — tolerant field getters over a raw `Map`.
2. `data/<x>_repository.dart` — one method per role branch, calling
   `ApiClient.get/post` with the right `ApiEndpoints` constant.
3. `presentation/providers/<x>_provider.dart` — a `FutureProvider.autoDispose`
   keyed off the current user.
4. `presentation/screens/<x>_screen.dart` — wrap the provider in
   `AsyncValueView`.
5. Add the route in `core/routing/app_router.dart` and a tile in
   `DashboardShell._tilesFor`.
