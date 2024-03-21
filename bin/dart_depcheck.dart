#!/usr/bin/env dart

import 'package:args/args.dart';
import 'package:dart_depcheck/dart_depcheck.dart';

void _printBold(String text) => print('\u001b[1m$text\u001b[0m');
void _printGreen(String text) => print('\u001b[32m$text\u001b[0m');
void _printRed(String text) => print('\u001b[31m$text\u001b[0m');

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('path', abbr: 'p', help: 'Path to the Flutter/Dart project')
    ..addOption('folders', abbr: 'f', help: 'Additional folders to search')
    ..addOption('exclude', abbr: 'e', help: 'Packages to exclude')
    ..addFlag('help', abbr: 'h', help: 'Show usage help', negatable: false);
  try {
    final args = parser.parse(arguments);

    if (args['help']) {
      _printBold('Usage:');
      print(parser.usage);
      return;
    }
    final projectPath = args['path'] ?? '.';
    final additionalFolders = args['folders']?.split(',') as List<String>?;
    final excludePackages = args['exclude']?.split(',') as List<String>?;

    final (dep, devDep) = await DependencyChecker.check(
      projectPath: projectPath,
      additionalFolders: additionalFolders?.toSet(),
      excludePackages: excludePackages?.toSet(),
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
  } catch (e) {
    _printRed(e.toString());
    _printBold('Usage:');
    print(parser.usage);
  }
}
