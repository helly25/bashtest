# 0.4.1

# 0.4.0

* Renamed the module repo to `helly25_bashtest` and dropped the `com_helly25_bashtest` alias. The `bashtest` macro now resolves its runtime via a repo-relative `Label`, so it works regardless of the apparent repo name. Consumers must update `load("@helly25_bashtest//bashtest:bashtest.bzl", "bashtest")` (previously `@com_helly25_bashtest`).
* Dropped legacy `WORKSPACE` support; the module is now bzlmod-only.
* Extended the BCR presubmit support matrix: added Bazel 9.x and the Linux platforms ubuntu 22.04, Debian 12, and Rocky Linux 8 (alongside the existing ubuntu 24.04 and macOS).

# 0.3.1

* Re-release of 0.3.0 (no functional changes).

# 0.3.0

* Added explicit load of `sh_library` (needed for bazel 9).
* Upgraded dependencies: bazel 9.1.1, bazel_skylib 1.8.2, platforms 1.0.0, rules_shell 0.6.1.

# 0.2.0

* Added convenient target to print `bashtest` help `bazel run //bashtest:bashtest_help` which can be used with `|pandoc -s -t man|man -l -`.
* Fixed description for flag '--test_filter'.
* Added '--gtest_filter' which is an actual glob based filter (as opposed to '--test_filter' which uses posix regular expressions).
* Correct support for space separated flag values.

# 0.1.0

* Initial version moved from helly25_mbo//testing/bashtest*
