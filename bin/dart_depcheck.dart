#!/usr/bin/env dart

import 'package:args/args.dart';
import 'package:dart_depcheck/dart_depcheck.dart';

void _printBold(String text) => print('\u001b[1m$text\u001b[0m');
void _printGreen(String text) => print('\u001b[32m$text\u001b[0m');
void _printRed(String text) => print('\u001b[31m$text\u001b[0m');

void main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('path', abbr: 'p', help: 'Path to the Flutter/Dart project');
  parser.addOption('folders', abbr: 'f', help: 'Additional folders to search');
  parser.addOption('exclude', abbr: 'e', help: 'Packages to exclude');
  final args = parser.parse(arguments);

  final projectPath = args['path'] ?? '.';
  final additionalFolders = args['folders']?.split(',');
  final excludePackages = args['exclude']?.split(',');

  final (dep, devDep) = await DependencyChecker.check(
    projectPath: projectPath,
    additionalFolders: additionalFolders,
    excludePackages: excludePackages,
  );

  if (dep.isEmpty && devDep.isEmpty) {
    _printGreen('No unused dependencies found.');
    return;
  }

  if (dep.isNotEmpty) {
    _printBold('Unused dependencies:');
    _printRed(dep.join('\n'));
  }
  if (devDep.isNotEmpty) {
    _printBold('Unused dev dependencies:');
    _printRed(devDep.join('\n'));
  }
}
