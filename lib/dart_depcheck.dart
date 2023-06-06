import 'dart:convert';
import 'dart:io';
import 'package:yaml/yaml.dart';

/// A custom depcheck command for Flutter/Dart projects.
abstract class DependencyChecker {
  /// Checks for unused dependencies in the project.
  ///
  /// [projectPath] is the path to the project. Defaults to the current directory.
  /// [additionalFolders] is a list of additional folders to search for Dart files.
  ///
  /// Returns a [Future] with the result of the check as a [List<String>].
  /// For example, if there are unused dependencies, the list will contain the unused dependencies as `['yaml', 'path']`.
  static Future<(List<String> dependencies, List<String> devDependencies)>
      check({
    String projectPath = '.',
    List<String>? additionalFolders,
  }) async {
    final packageFile = File('$projectPath/pubspec.yaml');

    if (!packageFile.existsSync()) {
      throw Exception('pubspec.yaml was not found in $projectPath');
    }

    final pubspecContent = await packageFile.readAsString();
    final pubspecData = json.decode(json.encode(loadYaml(pubspecContent)));

    final dependencies = pubspecData['dependencies'] ?? {};
    final devDependencies = pubspecData['dev_dependencies'] ?? {};

    final usedPackages = <String>{};

    final foldersToSearch = [
      Directory('$projectPath/lib'),
      if (additionalFolders != null)
        ...additionalFolders.map((folder) => Directory(folder))
    ];

    // Goes through the Dart files of the project and additional folders, and finds the imported packages
    for (var folder in foldersToSearch) {
      await for (var file in folder.list(recursive: true)) {
        if (file is File && file.path.endsWith('.dart')) {
          final content = await file.readAsString();
          final imports = RegExp(r'package:(\w+)/').allMatches(content);

          for (var match in imports) {
            if (match.groupCount > 0) {
              final packageName = match.group(1);
              if (packageName == null) continue;
              usedPackages.add(packageName);
            }
          }
        }
      }
    }

    final unusedDependencies = <String>[];
    final unusedDevDependencies = <String>[];

    // Checks for unused dependencies and unused dev dependencies
    dependencies.forEach((dependency, _) {
      if (!usedPackages.contains(dependency)) {
        unusedDependencies.add(dependency);
      }
    });

    devDependencies.forEach((dependency, _) {
      if (!usedPackages.contains(dependency)) {
        unusedDevDependencies.add(dependency);
      }
    });

    if (unusedDependencies.isNotEmpty || unusedDevDependencies.isNotEmpty) {
      return (unusedDependencies, unusedDevDependencies);
    }

    return (<String>[], <String>[]);
  }
}
