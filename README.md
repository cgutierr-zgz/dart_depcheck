# dart_depcheck

`dart_depcheck` is a command-line tool to check for **unused** and **missing** dependencies in Flutter/Dart projects.

- **Unused dependencies** — declared in `pubspec.yaml` (under `dependencies` or `dev_dependencies`) but never imported.
- **Missing dependencies** — imported in your source but not declared in `pubspec.yaml`.

<img src="https://raw.githubusercontent.com/cgutierr-zgz/dart_depcheck/main/screenshots/example.png" width="300">

## Installation 📥

Make sure you have the Dart SDK installed on your machine.

### Option 1: Global installation 💻

1. Install `dart_depcheck` globally:

```bash
dart pub global activate dart_depcheck

# Or locally by cloning the repository and running:
dart pub global activate --source path .
```

2. Run the dart_depcheck command in the root of your Flutter/Dart project to check for dependency issues:

```bash
dart_depcheck # Check the current directory.
dart_depcheck -p /path/to/project # Check the specified project path.
dart_depcheck -f bin,test # Also scan the bin and test folders (only lib is scanned by default).
dart_depcheck -e yaml,path # Exclude the specified packages from the check.

# Combine the options:
dart_depcheck -p /path/to/project -f bin,test -e yaml,path

# CI-friendly: exit with a non-zero code when issues are found.
dart_depcheck --fail-on-issues

# Machine-readable output.
dart_depcheck --json
dart_depcheck --summary

# Display the help message:
dart_depcheck --help
```

This checks the dependencies declared in the `pubspec.yaml` file and reports unused `dependencies`, unused `dev_dependencies`, and missing dependencies found in the project.

### Options

| Option              | Abbr | Description                                                          |
| ------------------- | ---- | -------------------------------------------------------------------- |
| `--path`            | `-p` | Path to the Flutter/Dart project (defaults to the current directory).|
| `--folders`         | `-f` | Comma-separated additional folders to scan, relative to the project. |
| `--exclude`         | `-e` | Comma-separated packages to exclude from the check.                  |
| `--json`            |      | Output the result as JSON.                                           |
| `--summary`         |      | Display a concise summary.                                           |
| `--fail-on-issues`  |      | Exit with code `1` when any issue is found (useful in CI).           |
| `--version`         |      | Show the current version.                                            |
| `--help`            | `-h` | Show usage help.                                                     |

> **Note:** detection is import-based and scans only the `lib` folder by default.
> Use `-f` to include folders such as `bin` and `test`. Packages that provide
> no importable API (e.g. `lints`, `build_runner`) are reported as unused —
> exclude them with `-e`.

### Option 2: Add as a Dependency 📦

You can also add `dart_depcheck` as a dependency in your Dart project and use it programmatically.

Add dart_depcheck to the dependencies section of your pubspec.yaml file:
```yaml
dependencies:
  dart_depcheck: ^1.1.0
```

Use `DependencyChecker.analyze` for the full result, including missing dependencies:

```dart
import 'package:dart_depcheck/dart_depcheck.dart';

void main() async {
  final result = await DependencyChecker.analyze(
    projectPath: '/path/to/project',
    additionalFolders: {'bin', 'test'},
    excludePackages: {'yaml', 'path'},
  );

  print(result.unusedDependencies);    // declared but never imported
  print(result.unusedDevDependencies); // declared dev deps never imported
  print(result.missingDependencies);   // imported but not declared
  print(result.isClean);               // true when there are no issues
}
```

`DependencyChecker.check` is still available and returns a record of
`(unusedDependencies, unusedDevDependencies)` if you only need unused detection:

```dart
import 'package:dart_depcheck/dart_depcheck.dart';

void main() async {
  final (dep, devDep) = await DependencyChecker.check();
}
```

## Continuous Integration 🤖

- **Pre-merge checks** — every pull request to `main` runs analysis, tests and
  coverage via [`.github/workflows/ci.yaml`](.github/workflows/ci.yaml).
  Coverage is enforced at **100%** (`min_coverage: 100`).
- **Publishing** — pushing a version tag (e.g. `v1.1.0`) triggers
  [`.github/workflows/publish.yaml`](.github/workflows/publish.yaml), which
  publishes the package to pub.dev (via GitHub OIDC, no secrets) and creates a
  GitHub release whose notes are taken from the matching `CHANGELOG.md` section.

### Cutting a release 🚀

Releases are driven by the changelog using [`cider`](https://pub.dev/packages/cider).
During development, record changes under the `## Unreleased` section of
`CHANGELOG.md` (manually, or with `cider log`):

```bash
dart run cider log added "New --foo flag"
dart run cider log fixed "Crash when pubspec is missing a name"
```

When ready to release, run the helper script. It bumps the version, promotes the
`Unreleased` section to the new version, commits, and creates the `v<version>` tag:

```bash
dart run tool/release.dart            # patch release (default)
dart run tool/release.dart minor      # or: major | patch | build | breaking | none
```

By default it does **not** push. Review the commit, then push the tag to publish:

```bash
git push --follow-tags
```

Or do it in one step with `--push`:

```bash
dart run tool/release.dart minor --push
```

You can also run any of these from VS Code — see the **Release: …** entries in
the Run & Debug panel, or the **Release: cut version** task. Pushing the tag
triggers pub.dev publishing and the GitHub release.

> The very first cider-based release is already at the target version
> (`1.1.0`), so cut it without a bump: `dart run tool/release.dart none`.

### Maintainer setup 🔧

These are one-time repository/pub.dev settings (cannot be configured from the
codebase):

- **Automated publishing** — on pub.dev go to the package admin page →
  *Automated publishing* → enable GitHub Actions publishing for
  `cgutierr-zgz/dart_depcheck` with the tag pattern `v{{version}}`.
- **Branch protection** — protect `main` so changes land via reviewed PRs with
  passing CI. With the [GitHub CLI](https://cli.github.com/):

  ```bash
  gh api -X PUT repos/cgutierr-zgz/dart_depcheck/branches/main/protection \
    --input - <<'JSON'
  {
    "required_status_checks": { "strict": true, "contexts": ["build"] },
    "enforce_admins": true,
    "required_pull_request_reviews": { "required_approving_review_count": 1 },
    "restrictions": null
  }
  JSON
  ```

## Contributing 🤝
If you encounter any issues or have any ideas for improvement, feel free to open an issue or submit a pull request on GitHub.

## License 📄
This project is licensed under the MIT License. See the LICENSE file for more details.