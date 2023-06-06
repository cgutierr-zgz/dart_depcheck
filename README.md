# dart_depcheck

`dart_depcheck` is a command-line tool to check for unused dependencies in Flutter/Dart projects.

## Usage

Make sure you have the Dart SDK installed on your machine.

### Option 1: Global installation

1. Install `dart_depcheck` globally:

```bash
dart pub global activate dart_depcheck
```

2. Run the dart_depcheck command in the root of your Flutter/Dart project to check for unused dependencies:

```bash
dart_depcheck
```

Optionally, you can specify the path to your project using the -p option:

```bash
dart_depcheck -p /path/to/project
```

You can also provide additional folders to search using the -f or --folders option. Separate the folder names with commas:

```bash
dart_depcheck -f lib,bin,test # This will include the specified additional folders (lib, bin, test) in the search for unused dependencies.
```

This will check the dependencies declared in the `pubspec.yaml` file and display a list of unused dependencies found in the project.

### Option 2: Add as a Dependency

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

You can also specify the project path and additional folders to search:

```dart
import 'package:dart_depcheck/dart_depcheck.dart';

void main() async {
  await DependencyChecker.check(
    projectPath: '/path/to/project',
    additionalFolders: ['lib', 'test', 'bin'],
  );
}
```

## Contributing
If you encounter any issues or have any ideas for improvement, feel free to open an issue or submit a pull request on GitHub.

## License
This project is licensed under the MIT License. See the LICENSE file for more details.

---
TODO
[ ] Add tests + coverage
[ ] Add pipelines for both publish and pre merge
[ ] ...