# bashtest.sh - A Bazel shell test runner.

This shell test library provides Bazel macro rules to simplify shell testing.

The library is tested with continuous integration: [![Test](https://github.com/helly25/bashtest/actions/workflows/main.yml/badge.svg)](https://github.com/helly25/bashtest/actions/workflows/main.yml).

## Bashtest

Run one of the following commands to get detailed information on the actual bashtest.sh script:

* `bazel run //bashtest:bashtest_help`
* `bazel run //bashtest:bashtest_help | pandoc -s -t man | man -l -`
* `bazel run //bashtest:bashtest_help | pandoc | lynx -stdin`

The flags can be used on the `bazel run` and `bazel test` commands (the latter requiring `--test_arg=...`).

### Functionality

* status helper `test_has_error`: Returns whether a test function has had an expectation error. This is reset for every test function.
* status helper `test_has_failed_tests`: Returns whether a test program had previous failing test functions.
* expectation `expect_eq` "\${LHS}" "\${RHS}": Asserts that two strings are the same.
* expectation `expect_ne` "\${LHS}" "\${RHS}": Asserts that two strings are different.
* expectation `expect_files_eq` "\${LHS}" "\${RHS}": Asserts that two file are the same (supports golden updates).
* expectation `expect_contains` "\${EXPECTED}" "\${ARRAY[@]}": Assert that one string is present in an array.
* expectation `expect_not_contains` "\${EXPECTED}" "\${ARRAY[@]}": Assert that one string is not present in an array.
* special test function `test::test_init`: If present, then this function runs first! Tests will only be executed if it succeeds.
* special test function `test::test_done`: If present, then this function runs last!

### Example

1) Write a test that sources bashtest.

```sh
set -euo pipefail

# shellcheck disable=SC1090,SC1091,SC2154
source "${helly25_bashtest}"

test::my_test() {
  expect_ne "Hello" "World"
  # Your tests go here...
}

# More tests go here...

test_runner
```

2) Write or extend a BUILD file

```bzl
load("@com_helly25_bashtest//bashtest:bashtest.bzl", "bashtest")

bashtest(
    name = "sh_test",
    srcs = ["sh_test.sh"],
)
```

## Installation and requirements

This repository bash to work (Linux, MacOs).

### WORKSPACE

Checkout [Releases](https://github.com/helly25/bashtest/releases) or use head ref as follows:

```
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
  name = "com_helly25_bashtest",
  url = "https://github.com/helly25/bashtest/archive/refs/heads/main.tar.gz",
  # See https://github.com/helly25/bashtest/releases for releases.
)
```

### MODULES.bazel

Check [Releases](https://github.com/helly25/bashtest/releases) for details. All that is needed is a `bazel_dep` instruction with the correct version.

```
bazel_dep(name = "helly25_bashtest", version = "0.0.0")
```
