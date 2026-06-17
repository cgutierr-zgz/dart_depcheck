// Cuts a release the same way our other repos do, but Dart-native (via cider).
//
// Steps:
//   1. Bumps the version in pubspec.yaml (skipped with "none").
//   2. Promotes the "Unreleased" changelog section to the new version + date.
//   3. Commits the change and creates a "v<version>" tag.
//   4. Optionally pushes (only with --push), which triggers pub.dev publishing.
//
// Usage:
//   dart run tool/release.dart [major|minor|patch|build|breaking|none] [--push]
//   dart run tool/release.dart --push-only   # just push pending commits + tags
//
// Runnable from the terminal, from VS Code tasks, or from the Run & Debug panel
// (see .vscode/launch.json / tasks.json).
import 'dart:io';

Future<void> main(List<String> args) async {
  // Push an already-cut release (commits + tags) without bumping again.
  if (args.contains('--push-only')) {
    stdout.writeln('==> Pushing pending commits + tags (publishes to pub.dev)');
    await _run('git', ['push', '--follow-tags']);
    stdout.writeln('Pushed — the publish workflow is now running.');
    return;
  }

  final push = args.contains('--push');
  final positional = args.where((a) => !a.startsWith('-')).toList();
  final bump = positional.isEmpty ? 'patch' : positional.first;

  const allowed = {'major', 'minor', 'patch', 'build', 'breaking', 'none'};
  if (!allowed.contains(bump)) {
    stderr.writeln('error: unknown bump "$bump". '
        'Use one of: ${allowed.join(', ')}.');
    exit(64);
  }

  final status = await _capture('git', ['status', '--porcelain']);
  if (status.trim().isNotEmpty) {
    stderr.writeln('error: working tree is not clean. Commit or stash first.');
    exit(1);
  }

  await _run('dart', ['pub', 'get']);
  if (bump != 'none') {
    stdout.writeln('==> Bumping version ($bump)');
    await _run('dart', ['run', 'cider', 'bump', bump]);
  }
  stdout.writeln('==> Promoting Unreleased changelog entries');
  await _run('dart', ['run', 'cider', 'release']);

  final version = (await _capture('dart', ['run', 'cider', 'version'])).trim();
  final tag = 'v$version';

  await _run('git', ['add', 'pubspec.yaml', 'CHANGELOG.md']);
  await _run('git', ['commit', '-m', 'chore: release $tag']);
  await _run('git', ['tag', tag]);

  stdout.writeln('\nReleased $tag locally.');

  if (push) {
    stdout.writeln('==> Pushing (this publishes to pub.dev)');
    await _run('git', ['push', '--follow-tags']);
    stdout.writeln('Pushed $tag — the publish workflow is now running.');
  } else {
    stdout.writeln('Review the commit, then publish by pushing the tag:\n'
        '    git push --follow-tags');
  }
}

/// Runs [executable] inheriting stdio; exits the process on failure.
Future<void> _run(String executable, List<String> args) async {
  final process = await Process.start(
    executable,
    args,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    stderr.writeln('error: `$executable ${args.join(' ')}` failed ($code).');
    exit(code);
  }
}

/// Runs [executable] and returns its stdout.
Future<String> _capture(String executable, List<String> args) async {
  final result = await Process.run(executable, args);
  if (result.exitCode != 0) {
    stderr.writeln('error: `$executable ${args.join(' ')}` failed '
        '(${result.exitCode}).\n${result.stderr}');
    exit(result.exitCode);
  }
  return result.stdout as String;
}
