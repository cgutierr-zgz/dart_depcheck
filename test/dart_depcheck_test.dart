import 'dart:io';
import 'package:dart_depcheck/dart_depcheck.dart';
import 'package:dart_depcheck/src/errors.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('DependencyChecker', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('dependency_checker_test');
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('check - all dependencies used', () async {
      final projectPath = tempDir.path;

      final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
        name: test_project
        dependencies:
          package_a: ^1.0.0
          package_b: ^2.0.0
      ''');

      final libDir = Directory(path.join(projectPath, 'lib'));
      libDir.createSync(recursive: true);
      final dartFile = File(path.join(libDir.path, 'main.dart'));
      dartFile.writeAsStringSync('''
        import 'package:package_a/package_a.dart';
        import 'package:package_b/package_b.dart';
        void main() {}
      ''');

      final (dep, devDep) =
          await DependencyChecker.check(projectPath: projectPath);

      expect(dep, isEmpty);
      expect(devDep, isEmpty);
    });

    test('check - unused dependencies and dev dependencies', () async {
      final projectPath = tempDir.path;

      final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
        name: test_project
        dependencies:
          package_a: ^1.0.0
          package_b: ^2.0.0
        dev_dependencies:
          package_c: ^3.0.0
      ''');

      final libDir = Directory(path.join(projectPath, 'lib'));
      libDir.createSync(recursive: true);
      final dartFile = File(path.join(libDir.path, 'main.dart'));
      dartFile.writeAsStringSync('''
        import 'package:package_a/package_a.dart';
        void main() {}
      ''');

      final (dep, devDep) =
          await DependencyChecker.check(projectPath: projectPath);

      expect(dep, contains('package_b'));
      expect(devDep, contains('package_c'));
    });

    test('check - unused dependencies', () async {
      final projectPath = tempDir.path;

      final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
        name: test_project
        dependencies:
          package_a: ^1.0.0
          package_b: ^2.0.0
        dev_dependencies:
          package_c: ^3.0.0
      ''');

      final libDir = Directory(path.join(projectPath, 'lib'));
      libDir.createSync(recursive: true);
      final dartFile = File(path.join(libDir.path, 'main.dart'));
      dartFile.writeAsStringSync('''
import 'package:package_a/package_a.dart';
import 'package:package_c/package_c.dart';
void main() {}
''');

      final (dep, devDep) =
          await DependencyChecker.check(projectPath: projectPath);

      expect(dep, contains('package_b'));
      expect(devDep, isEmpty);
    });

    test('check - unused dev dependencies', () async {
      final projectPath = tempDir.path;

      final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
        name: test_project
        dependencies:
          package_a: ^1.0.0
          package_b: ^2.0.0
        dev_dependencies:
          package_c: ^3.0.0
      ''');

      final libDir = Directory(path.join(projectPath, 'lib'));
      libDir.createSync(recursive: true);
      final dartFile = File(path.join(libDir.path, 'main.dart'));
      dartFile.writeAsStringSync('''
import 'package:package_a/package_a.dart';
import 'package:package_b/package_b.dart';
void main() {}
''');

      final (dep, devDep) =
          await DependencyChecker.check(projectPath: projectPath);

      expect(dep, isEmpty);
      expect(devDep, contains('package_c'));
    });

    test('check - invalid project path', () async {
      final projectPath = tempDir.path;

      final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
        name: test_project
        dependencies:
          package_a: ^1.0.0
          package_b: ^2.0.0
        dev_dependencies:
          package_c: ^3.0.0
      ''');

      final libDir = Directory(path.join(projectPath, 'lib'));
      libDir.createSync(recursive: true);
      final dartFile = File(path.join(libDir.path, 'main.dart'));
      dartFile.writeAsStringSync('''
import 'package:package_a/package_a.dart';
import 'package:package_b/package_b.dart';
void main() {}
''');

      expect(() async {
        await DependencyChecker.check(projectPath: 'invalid_path');
      }, throwsA(isA<PubspecNotFoundError>()));

      try {
        await DependencyChecker.check(projectPath: 'invalid_path');
      } catch (e) {
        expect(e.toString(),
            contains('pubspec.yaml was not found in invalid_path'));
      }
    });

    test('check - additional folders', () async {
      final projectPath = tempDir.path;

      final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
        name: test_project
        dependencies:
          package_a: ^1.0.0
        dev_dependencies:
          package_b: ^2.0.0
      ''');

      final libDir = Directory(path.join(projectPath, 'lib'));
      libDir.createSync(recursive: true);
      final dartFile = File(path.join(libDir.path, 'main.dart'));
      dartFile.writeAsStringSync('''
import 'package:package_a/package_a.dart';
void main() {}
''');

      final testDir = Directory(path.join(projectPath, 'test'));
      testDir.createSync(recursive: true);
      final testFile = File(path.join(testDir.path, 'main_test.dart'));
      testFile.writeAsStringSync('''
import 'package:package_b/package_b.dart';
void main() {}
''');

      final (dep, devDep) = await DependencyChecker.check(
        projectPath: projectPath,
        additionalFolders: {'test'},
      );

      expect(dep, isEmpty);
      expect(devDep, isEmpty);
    });

    test('check - excluded packages', () async {
      final projectPath = tempDir.path;

      final pubspecFile = File(path.join(projectPath, 'pubspec.yaml'));
      pubspecFile.writeAsStringSync('''
        name: test_project
        dependencies:
          package_a: ^1.0.0
          package_b: ^2.0.0
        dev_dependencies:
          package_c: ^3.0.0
      ''');

      final libDir = Directory(path.join(projectPath, 'lib'));
      libDir.createSync(recursive: true);
      final dartFile = File(path.join(libDir.path, 'main.dart'));
      dartFile.writeAsStringSync('''
void main() {}
''');

      final (dep, devDep) = await DependencyChecker.check(
        projectPath: projectPath,
        excludePackages: {'package_b'},
      );

      expect(dep, contains('package_a'));
      expect(devDep, contains('package_c'));
    });
  });
}
