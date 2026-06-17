#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_depcheck/dart_depcheck.dart';

void _printBold(String text) => print('\u001b[1m$text\u001b[0m');
void _printGreen(String text) => print('\u001b[32m$text\u001b[0m');
void _printRed(String text) => print('\u001b[31m$text\u001b[0m');

const String version = '1.1.0';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('path', abbr: 'p', help: 'Path to the Flutter/Dart project')
    ..addOption('folders', abbr: 'f', help: 'Additional folders to search')
    ..addOption('exclude', abbr: 'e', help: 'Packages to exclude')
    ..addFlag('help', abbr: 'h', help: 'Show usage help', negatable: false)
    ..addFlag(
      'json',
      help: 'Output results in JSON format',
      negatable: false,
    )
    ..addFlag(
      'summary',
      help: 'Display a concise summary',
      negatable: false,
    )
    ..addFlag(
      'fail-on-issues',
      help: 'Exit with a non-zero code when issues are found (useful in CI)',
      negatable: false,
    )
    ..addFlag(
      'version',
      help: 'Show the current version',
      negatable: false,
    );
  try {
    final args = parser.parse(arguments);

    if (args['help']) {
      _printBold('Usage:');
      print(parser.usage);
      return;
    }
    if (args['version']) {
      _printBold('dart_depcheck version: $version');
      return;
    }

    final projectPath = args['path'] ?? '.';
    final additionalFolders = args['folders']?.split(',') as List<String>?;
    final excludePackages = args['exclude']?.split(',') as List<String>?;

    final result = await DependencyChecker.analyze(
      projectPath: projectPath,
      additionalFolders: additionalFolders?.toSet(),
      excludePackages: excludePackages?.toSet(),
    );

    final dep = result.unusedDependencies;
    final devDep = result.unusedDevDependencies;
    final missing = result.missingDependencies;

    final bool failOnIssues = args['fail-on-issues'];
    void exitIfRequested() {
      if (failOnIssues && !result.isClean) exit(1);
    }

    if (args['json']) {
      print(jsonEncode(result.toJson()));
      exitIfRequested();
      return;
    }

    if (args['summary']) {
      final totalIssues = dep.length + devDep.length + missing.length;
      if (totalIssues == 0) {
        _printGreen('No dependency issues found.');
      } else {
        _printBold('Summary:');
        _printRed('$totalIssues dependency issue(s) found.');
        if (dep.isNotEmpty) {
          _printBold('Unused dependencies:');
          _printRed(dep.join('\n'));
        }
        if (devDep.isNotEmpty) {
          _printBold('Unused dev dependencies:');
          _printRed(devDep.join('\n'));
        }
        if (missing.isNotEmpty) {
          _printBold('Missing dependencies:');
          _printRed(missing.join('\n'));
        }
        _printBold('Consider fixing them to keep your project clean.');
      }
      exitIfRequested();
      return;
    }

    if (result.isClean) {
      _printGreen('No dependency issues found.');
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
    if (missing.isNotEmpty) {
      _printBold('Missing dependencies (imported but not declared):');
      _printRed(missing.join('\n'));
    }
    exitIfRequested();
  } catch (e) {
    _printRed(e.toString());
    _printBold('Usage:');
    print(parser.usage);
  }
}
