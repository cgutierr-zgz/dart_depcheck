class PubspecNotFoundError extends Error {
  final String path;

  PubspecNotFoundError(this.path);

  @override
  String toString() => 'pubspec.yaml was not found in $path';
}
