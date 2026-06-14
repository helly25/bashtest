# 0.3.2

* Extended the BCR presubmit support matrix: added Bazel 9.x and the Linux platforms ubuntu 22.04, Debian 12, and Rocky Linux 8 (alongside the existing ubuntu 24.04 and macOS).

# 0.3.1

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
