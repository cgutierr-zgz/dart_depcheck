#!/usr/bin/env dart

import 'dart:convert';

import 'package:args/args.dart';
import 'package:dart_depcheck/dart_depcheck.dart';

void _printBold(String text) => print('\u001b[1m$text\u001b[0m');
void _printGreen(String text) => print('\u001b[32m$text\u001b[0m');
void _printRed(String text) => print('\u001b[31m$text\u001b[0m');

const String version = '1.0.1';

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

    final (dep, devDep) = await DependencyChecker.check(
      projectPath: projectPath,
      additionalFolders: additionalFolders?.toSet(),
      excludePackages: excludePackages?.toSet(),
    );

    if (args['json']) {
      final result = {
        'unusedDependencies': dep.toList(),
        'unusedDevDependencies': devDep.toList(),
      };
      print(jsonEncode(result));
      return;
    }

    if (args['summary']) {
      final totalUnused = dep.length + devDep.length;
      if (totalUnused == 0) {
        _printGreen('No unused dependencies found.');
      } else {
        _printBold('Summary:');
        _printRed('$totalUnused unused dependencies found.');
        _printBold('Unused dependencies:');
        _printRed(dep.join('\n'));
        _printBold('Unused dev dependencies:');
        _printRed(devDep.join('\n'));
        _printBold('Consider removing them to keep your project clean.');
      }
      return;
    }

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
