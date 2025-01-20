# GitHub Advanced Security (GHAS) Proof of Concept Demonstrations

This repository contains demonstration materials for GitHub Advanced Security (GHAS) Proof of Concept (PoC) evaluations conducted with GitHub. 
It includes three sample projects within the `projects` folder, all of which can be built using Bazel.

## Projects Overview

### Go Language
- **go_web**: A simple "Hello, World!" application running on a web server.

### Python Language
- **python_calculator**: A basic calculator application.
- **python_vulnerable_app**: A "Hello, World!" application running on Python/Flask with intentional vulnerabilities for CodeQL detection.

## Building Projects on Ubuntu

To build the projects, follow the instructions below:

- Build all projects:
  ```
  bazel build //...
  ```

- Build the Go project:
  ```
  bazel build //projects/go_web:go_web --verbose_failures
  ```

- Build the Python project:
  ```
  bazel build //projects/python_vulnerable_app:main --verbose_failures
  ```

## Running Projects on Ubuntu

To execute the projects, use the following commands:

- Run the Go project:
  ```
  bazel run //projects/go_web:go_web --verbose_failures
  ```

- Run the Python project:
  ```
  bazel run //projects/python_vulnerable_app:main --verbose_failures
  ```

## Code Scanning with CodeQL

CodeQL supports three different build modes when executing CodeQL scans:

1. **none**: Creates the database without building the source root. Supported for C#, Java, JavaScript/TypeScript, Python, and Ruby.
2. **autobuild**: Attempts to automatically build the source root. Supported for C/C++, C#, Go, Java/Kotlin, and Swift.
3. **manual**: Creates the database by building the source root using a manually specified build command. Supported for C/C++, C#, Go, Java/Kotlin, and Swift.

**Recommendation**: Start with the "none" mode. If issues or warnings occur, switch to "autobuild." If "autobuild" fails, resort to the "manual" mode.

## How This PoC Works

In this PoC, we assume the client will run CodeQL on a third-party CI (e.g., Jenkins). We provided scripts to facilitate this:

- `codeql_cli_python.sh`: Executes a Python CodeQL scan using `CodeQL CLI` and `build-mode=none`. It runs as expected.
- `codeql_cli_bazel_build_go.sh`: Attempts to build Go code using Bazel, which is currently not supported. Here's why:

For Go, CodeQL does not support builds with Bazel. Bazel does not utilize the standard Go build tooling (i.e., `go build`). Due to this discrepancy, adding support for Bazel-built Go projects is non-trivial. GitHub monitors the demand for such support and may consider it in the future, though there are no current plans. This issue is documented at: [GitHub Issue #17458](https://github.com/github/codeql/issues/17458).
