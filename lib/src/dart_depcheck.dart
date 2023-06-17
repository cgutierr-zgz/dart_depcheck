import 'dart:convert';
import 'dart:io';
import 'package:dart_depcheck/src/errors.dart';
import 'package:yaml/yaml.dart';

/// A custom depcheck command for Flutter/Dart projects.
abstract class DependencyChecker {
  /// Checks for unused dependencies in the project.
  ///
  /// [projectPath] is the path to the project. Defaults to the current directory.
  /// [additionalFolders] is a list of additional folders to search for Dart files, by default it only searches the `lib` folder.
  /// [excludePackages] is a list of packages to exclude from the unused dependency check.
  ///
  /// Returns a [Future] with the result of the check as a [Set<String> dependencies, Set<String> devDependencies].
  /// For example, if there are unused dependencies, the list will contain the unused dependencies as `['yaml', 'path']`.
  ///
  /// Usage:
  /// ```dart
  /// final (dep, devDep) = await DependencyChecker.check(
  ///  projectPath: projectPath,
  ///  additionalFolders: ['bin', 'test'],
  ///  excludePackages: ['yaml', 'path'],
  /// );
  /// ```
  static Future<(Set<String> dependencies, Set<String> devDependencies)> check({
    String projectPath = '.',
    Set<String>? additionalFolders,
    Set<String>? excludePackages,
  }) async {
    final packageFile = _getPackageFile(projectPath);
    final pubspecContent = await _readPubspecFile(packageFile);
    final pubspecData = _parsePubspecContent(pubspecContent);

    final usedPackages = await _findUsedPackages(
      projectPath,
      additionalFolders,
    );

    final unusedDependencies = _findUnusedDependencies(
      pubspecData['dependencies'],
      usedPackages,
      excludePackages,
    );
    final unusedDevDependencies = _findUnusedDependencies(
      pubspecData['dev_dependencies'],
      usedPackages,
      excludePackages,
    );

    return (unusedDependencies, unusedDevDependencies);
  }

  static File _getPackageFile(String projectPath) {
    final packageFile = File('$projectPath/pubspec.yaml');
    if (!packageFile.existsSync()) throw PubspecNotFoundError(projectPath);

    return packageFile;
  }

  static Future<String> _readPubspecFile(File packageFile) async =>
      await packageFile.readAsString();

  static Map<String, dynamic> _parsePubspecContent(String pubspecContent) {
    final pubspecData = json.decode(json.encode(loadYaml(pubspecContent)));
    return pubspecData;
  }

  static Future<Set<String>> _findUsedPackages(
      String projectPath, Set<String>? additionalFolders) async {
    final usedPackages = <String>{};
    final foldersToSearch = [
      Directory('$projectPath/lib'),
      if (additionalFolders != null)
        ...additionalFolders.map((folder) => Directory(folder))
    ];
    final existingFolders =
        foldersToSearch.where((folder) => folder.existsSync()).toList();

    for (var folder in existingFolders) {
      await for (var file in folder.list(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          final content = await file.readAsString();
          final imports = RegExp(r'package:(\w+)/').allMatches(content);

          for (var match in imports) {
            final packageName = match.group(1);
            if (packageName != null) {
              usedPackages.add(packageName);
            }
          }
        }
      }
    }

    return usedPackages;
  }

  static Set<String> _findUnusedDependencies(Map<String, dynamic>? dependencies,
      Set<String> usedPackages, Set<String>? excludePackages) {
    final unusedDependencies = <String>{};

    dependencies?.forEach((dependency, _) {
      if (!usedPackages.contains(dependency) &&
          (excludePackages == null || !excludePackages.contains(dependency))) {
        unusedDependencies.add(dependency);
      }
    });

    return unusedDependencies;
  }
}
