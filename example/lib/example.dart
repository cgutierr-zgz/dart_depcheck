import 'dart:io';

import 'package:dart_depcheck/dart_depcheck.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;

void main() async {
  // We create a random directory and add some temp files to it
  Directory tempDir =
      Directory.systemTemp.createTempSync('dependency_checker_test');

  final projectPath = tempDir.path;

  final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
  pubspecFile.writeAsStringSync('''
        name: test_project
        dependencies:
          package_a: ^1.0.0
          package_b: ^2.0.0
          package_c: ^3.0.0
        dev_dependencies:
          package_d: ^4.0.0
          package_e: ^5.0.0
      ''');

  final libDir = Directory(path.join(projectPath, 'lib'));
  libDir.createSync(recursive: true);
  final dartFile = File(path.join(libDir.path, 'main.dart'));
  dartFile.writeAsStringSync('''
        import 'package:package_a/package_a.dart';
        import 'package:package_b/package_b.dart';
        import 'package:undeclared_pkg/undeclared_pkg.dart';
        void main() {}
      ''');

  // This is how you use it
  final result = await DependencyChecker.analyze(
    projectPath: projectPath,
  );

  print('Unused dependencies: ${result.unusedDependencies}');
  print('Unused dev_dependencies: ${result.unusedDevDependencies}');
  print('Missing dependencies: ${result.missingDependencies}');
  print('Clean: ${result.isClean}');

  tempDir.deleteSync(recursive: true);
}
