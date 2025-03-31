# 0.2.0

* Added convenient target to print `bashtest` help `bazel run //bashtest:bashtest_help` which can be used with `|pandoc -s -t man|man -l -`.
* Fixed description for flag '--test_filter'.
* Added '--gtest_filter' which is an actual glob based filter (as opposed to '--test_filter' which uses posix regular expressions).
* Correct support for space separated flag values.

# 0.1.0

* Initial version moved from helly25_mbo//testing/bashtest*
