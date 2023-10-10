# dart_depcheck

`dart_depcheck` is a command-line tool to check for unused dependencies in Flutter/Dart projects.

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

2. Run the dart_depcheck command in the root of your Flutter/Dart project to check for unused dependencies:

Optionally, you can specify the path to your project using the -p option, add additional folders to search using the -f or --folders option, and exclude packages from the unused dependency check using the -e or --exclude option:

```bash
dart_depcheck # This will check the current directory for unused dependencies.
dart_depcheck -p /path/to/project # This will check the specified project path for unused dependencies.
dart_depcheck -f bin,test # This will include the specified additional folders (lib, bin, test) in the search for unused dependencies.
dart_depcheck -e yaml,path # This will exclude the specified packages (yaml, path) from the unused dependency check.

# You can also combine the options:
dart_depcheck -p /path/to/project -f bin,test -e yaml,path

# To display the help message:
dart_depcheck --help
```

This will check the dependencies declared in the `pubspec.yaml` file and display a list of both unused dependencies and dev_dependencies found in the project.

### Option 2: Add as a Dependency 📦

You can also add `dart_depcheck` as a dependency in your Dart project and use it programmatically.

Add dart_depcheck to the dependencies section of your pubspec.yaml file:
```yaml
dependencies:
  dart_depcheck: ^0.0.1
```

Import the package and use the **DependencyChecker** method in your code:

```dart
import 'package:dart_depcheck/dart_depcheck.dart';

void main() async {
  await DependencyChecker.check();
}
```

You can also specify the project path, additional folders to search and packages to exclude:

```dart
import 'package:dart_depcheck/dart_depcheck.dart';

void main() async {
  await DependencyChecker.check(
    projectPath: '/path/to/project',
    additionalFolders: ['bin', 'test'],
    excludePackages: ['yaml', 'path'],
  );
}
```

## Contributing 🤝
If you encounter any issues or have any ideas for improvement, feel free to open an issue or submit a pull request on GitHub.

## License 📄
This project is licensed under the MIT License. See the LICENSE file for more details.

---
## TODO 📝
- [ ] Add CI/CD for premerge checks + Generate coverage report on CI
- [ ] Add CI/CD for publishing to pub.dev and create a GitHub release
- [ ] Add branch protection rules