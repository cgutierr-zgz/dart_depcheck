# Contributing to dart_depcheck

Thank you for your interest in contributing to dart_depcheck! We welcome contributions from the community to help improve and enhance the project.

## How to Contribute

To contribute to dart_depcheck, please follow these steps:

1. Check if there is an existing issue or pull request that addresses your contribution, and if not, open a new issue to discuss your contribution with the maintainers, see [Reporting Issues](#reporting-issues) for more information.

1. Fork the repository and create a new branch for your contribution.

2. Make your desired changes or additions to the codebase, following the [Code Style](#code-style) guidelines.

3. Write tests to ensure the correctness of your changes and ensure that all tests pass successfully by running the test suite locally, see [Running the Tests](#running-the-tests) for more information.

4. Commit your changes and push them to your forked repository.

5. Open a pull request from your forked repository's branch to the main repository's `main`.

6. Ensure that the pull request template is filled out correctly and that the title of your pull request follows the [Conventional Commits](https://www.conventionalcommits.org/) specification. for your pull request and explain the changes you have made.

7. Wait for the maintainers to review your pull request. We will provide feedback and work with you to refine the changes if necessary.

8. Once your pull request is approved, it will be merged into the main repository.

## Reporting Issues

If you encounter any issues while using dart_depcheck or have any suggestions for improvement, please open an issue on the [GitHub issue tracker](https://github.com/cgutierr-zgz/dart_depcheck/issues). Provide a clear and detailed description of the problem or suggestion, along with any relevant information or steps to reproduce the issue.

## Code Style

When contributing to dart_depcheck, please adhere to the existing code style and conventions used in the project. This includes following proper indentation, naming conventions, and code organization.
For a simple way to format your code, run the following command:

```bash
dart format .
```

## Running the Tests

To run all tests, run the following command:

```bash
dart run test --coverage=./coverage && dart pub global activate coverage && dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib --lcov -o ./coverage/lcov.info -i ./coverage && genhtml -o ./coverage/report ./coverage/lcov.info && open ./coverage/report/index.html

# Or if you already have coverage activated

dart run test --coverage=./coverage  && dart pub global run coverage:format_coverage --packages=.dart_tool/package_config.json --report-on=lib --lcov -o ./coverage/lcov.info -i ./coverage && genhtml -o ./coverage/report ./coverage/lcov.info && open ./coverage/report/index.html
```

## Code of Conduct

Please note that by contributing to dart_depcheck, you are expected to follow the project's [Code of Conduct](CODE_OF_CONDUCT.md). Be respectful and considerate towards others, and help us maintain a welcoming and inclusive community.

We appreciate your contributions to dart_depcheck and look forward to working with you to improve the project!
