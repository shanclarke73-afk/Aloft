# Aloft app (Flutter)

iPhone and Android app. Plan: [../SPEC.md](../SPEC.md); progress: [../STATUS.md](../STATUS.md).

```bash
flutter pub get
flutter test
flutter run
```

- After changing a table in `lib/data/database.dart`, run `dart run build_runner build` and commit the
  updated `database.g.dart`.
- The database is encrypted with SQLCipher. It's built by the `sqlite3` package (see `hooks:` in
  `pubspec.yaml`); the older `sqlcipher_flutter_libs` package named in the spec is no longer needed.
- Bundle ID / application ID: `com.shannonsonlinebookkeeping.aloft`.
