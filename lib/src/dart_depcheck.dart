import 'dart:convert';
import 'dart:io';
import 'package:dart_depcheck/src/errors.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// The result of a dependency check.
///
/// Holds the [unusedDependencies] and [unusedDevDependencies] (declared in
/// `pubspec.yaml` but never imported) as well as the [missingDependencies]
/// (imported in the source but not declared in `pubspec.yaml`).
class DepcheckResult {
  /// Declared `dependencies` that are never imported.
  final Set<String> unusedDependencies;

  /// Declared `dev_dependencies` that are never imported.
  final Set<String> unusedDevDependencies;

  /// Packages imported in the source but not declared in `pubspec.yaml`.
  final Set<String> missingDependencies;

  /// Creates a [DepcheckResult].
  const DepcheckResult({
    required this.unusedDependencies,
    required this.unusedDevDependencies,
    required this.missingDependencies,
  });

  /// Whether the project has no unused and no missing dependencies.
  bool get isClean =>
      unusedDependencies.isEmpty &&
      unusedDevDependencies.isEmpty &&
      missingDependencies.isEmpty;

  /// Serializes the result to a JSON-friendly [Map].
  Map<String, List<String>> toJson() => {
        'unusedDependencies': unusedDependencies.toList(),
        'unusedDevDependencies': unusedDevDependencies.toList(),
        'missingDependencies': missingDependencies.toList(),
      };
}

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
  /// For richer output (including missing dependencies) use [analyze].
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
    final result = await analyze(
      projectPath: projectPath,
      additionalFolders: additionalFolders,
      excludePackages: excludePackages,
    );

    return (result.unusedDependencies, result.unusedDevDependencies);
  }

  /// Analyzes the project for unused and missing dependencies.
  ///
  /// [projectPath] is the path to the project. Defaults to the current directory.
  /// [additionalFolders] is a list of additional folders (relative to
  /// [projectPath]) to search for Dart files, by default it only searches the
  /// `lib` folder.
  /// [excludePackages] is a list of packages to exclude from both the unused
  /// and the missing dependency checks.
  ///
  /// Returns a [Future] with a [DepcheckResult].
  ///
  /// Usage:
  /// ```dart
  /// final result = await DependencyChecker.analyze(
  ///  projectPath: projectPath,
  ///  additionalFolders: {'bin', 'test'},
  ///  excludePackages: {'yaml', 'path'},
  /// );
  /// print(result.missingDependencies);
  /// ```
  static Future<DepcheckResult> analyze({
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

    final dependencies = pubspecData['dependencies'] as Map<String, dynamic>?;
    final devDependencies =
        pubspecData['dev_dependencies'] as Map<String, dynamic>?;

    final unusedDependencies = _findUnusedDependencies(
      dependencies,
      usedPackages,
      excludePackages,
    );
    final unusedDevDependencies = _findUnusedDependencies(
      devDependencies,
      usedPackages,
      excludePackages,
    );
    final missingDependencies = _findMissingDependencies(
      usedPackages,
      dependencies,
      devDependencies,
      pubspecData['name'] as String?,
      excludePackages,
    );

    return DepcheckResult(
      unusedDependencies: unusedDependencies,
      unusedDevDependencies: unusedDevDependencies,
      missingDependencies: missingDependencies,
    );
  }

  static File _getPackageFile(String projectPath) {
    final packageFile = File(p.join(projectPath, 'pubspec.yaml'));
    if (!packageFile.existsSync()) throw PubspecNotFoundError(projectPath);

    return packageFile;
  }

  static Future<String> _readPubspecFile(File packageFile) async =>
      await packageFile.readAsString();

  static Map<String, dynamic> _parsePubspecContent(String pubspecContent) {
    final pubspecData = json.decode(json.encode(loadYaml(pubspecContent)));
    return pubspecData as Map<String, dynamic>;
  }

  static Future<Set<String>> _findUsedPackages(
      String projectPath, Set<String>? additionalFolders) async {
    final usedPackages = <String>{};
    final foldersToSearch = [
      Directory(p.join(projectPath, 'lib')),
      if (additionalFolders != null)
        ...additionalFolders
            .map((folder) => Directory(p.join(projectPath, folder)))
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

  static Set<String> _findMissingDependencies(
    Set<String> usedPackages,
    Map<String, dynamic>? dependencies,
    Map<String, dynamic>? devDependencies,
    String? packageName,
    Set<String>? excludePackages,
  ) {
    final declared = <String>{
      ...?dependencies?.keys,
      ...?devDependencies?.keys,
    };

    return usedPackages.where((package) {
      if (declared.contains(package)) return false;
      // Self-imports (the package importing itself) are not external deps.
      if (package == packageName) return false;
      if (excludePackages != null && excludePackages.contains(package)) {
        return false;
      }
      return true;
    }).toSet();
  }
}
