# Changelog
## 2.0.3 - 2026-06-17
## 2.0.2 - 2026-06-17
## 2.0.1 - 2026-06-17
## 2.0.0 - 2026-06-17
### Added
- Detect missing dependencies (packages imported in the source but not declared in `pubspec.yaml`).
- `DependencyChecker.analyze` returning a `DepcheckResult` (`unusedDependencies`, `unusedDevDependencies`, `missingDependencies`, `isClean`, `toJson`).
- `--fail-on-issues` flag to exit with a non-zero code when issues are found (useful in CI).

### Changed
- Bump `lints` to `^6.0.0` and `test` to `^1.31.0`.

### Fixed
- Additional folders (`-f`/`--folders`) are now resolved relative to the project path (`-p`) instead of the current working directory.

### Removed
- Unused `pubspec_parse` dependency.

## 1.0.1 - 2025-04-15
### Fixed
- JSON output format issue.

## 1.0.0 - 2025-04-15
### Added
- `--json` flag for JSON output format.
- `--summary` flag for concise summary output.
- `--version` flag to display the package version.

### Changed
- Update dependencies.

## 0.1.0 - 2023-10-10
### Changed
- Update core libraries.

## 0.0.1-dev.6+1 - 2023-06-17
### Changed
- Small documentation updates.

## 0.0.1-dev.6 - 2023-06-17
### Changed
- Convert all lists to sets to avoid duplicates.
- Improve test coverage.

## 0.0.1-dev.5 - 2023-06-14
### Added
- `PubspecNotFoundError` exception.

### Changed
- Split the code into smaller functions.

## 0.0.1-dev.4 - 2023-06-07
### Added
- `--help` option.

### Fixed
- Small CLI fixes and improvements.

## 0.0.1-dev.3 - 2023-06-07
### Added
- 100% test coverage.
- GitHub Actions CI workflow.

### Changed
- Skip folders that don't exist to avoid errors.
- Improve `CONTRIBUTING.md`.

## 0.0.1-dev.2 - 2023-06-07
### Added
- `excludePackages` parameter.
- Example.
- Screenshot and README improvements.

### Changed
- Improve the pub.dev package description.

## 0.0.1-dev.1 - 2023-06-07
### Added
- Initial version.
