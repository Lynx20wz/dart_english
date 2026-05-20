# Commit Convention

This project sets commit message conventions.

## Commit Message Format

Commit messages should follow this structure:

```md
[<type>] (<module> v<package_version>) <description>

<optional description>

- `<scope>`: <action in past tense> <description>
- `<scope>`: `<initial_name>` -> `<updated_name>`
- `<scope>`:
  1) <action in past tense> <description>
  2) ...
```

Where:
- `<module>`: Target module identifier
  - `CM` — Core module (all path relative to `packages/english_core`)
  - `EH` — English Helper app (all path relative to `packages/english_helper`)
- `v<package_version>`: Current package version from `pubspec.yaml`. Must match exactly.
- `<type>`: Change type. Allowed values: `feat`, `fix`, `ref`, `perf`, `docs`, `test`, `chore`.
- `<scope>`: File, directory, or code entity name.
- `<description>`: Concise explanation of changes.
- `<optional description>`: Optional context or explanation of the commit's purpose

## Rules
- All paths and code objects (methods, classes, variables, types) must be wrapped in backticks: `WordPair`.
- Keep commits atomic. If changes span multiple unrelated scopes, split them.
- Use past tense for actions: `Added`, `Fixed`, `Moved`, `Updated`, `Overrode`.

## Example
```md
[fix] (CM v0.2.1) Updated WordPair and WordFile classes

- `WordPair`:
  1) Both `original` and `translate` fields are lowercased and trimmed upon assignment
  2) Overrode `==` and `hashCode` methods
- `WordFile`:
  1) `properties` -> `props`
  2) Updated property processing logic
```
