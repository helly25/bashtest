# com_helly25_bashtest//bashtest

Bashtest provides `sh_test` wrapper that simplifies the creation of shell tests.


  * bashtest:bashtest, bashtest/bashtest.sh
  * sh_library `bashtest.sh` which provides a test runner for complex shell tests involving golden files that provides built-in golden update functionality (see `(. bashtest/bashtest.sh --help)`).
    * status helper `test_has_erro`: Returns whether a test function has had an error.
    * status helper `test_has_failed_tests`: Returns whether a test program had previous failing test functions.
    * expectation `expect_eq` "\${LHS}" "\${RHS}": Asserts that two strings are the same.
    * expectation `expect_ne` "\${LHS}" "\${RHS}": Asserts that two strings are different.
    * expectation `expect_files_eq` "\${LHS}" "\${RHS}": Asserts that two file are the same (supports golden updates).
    * expectation `expect_contains` "\${EXPECTED}" "\${ARRAY[@]}": Assert that one string is present in an array.
    * expectation `expect_not_contains` "\${EXPECTED}" "\${ARRAY[@]}": Assert that one string is not present in an array.
    * special test function `test::test_init`: If present, then this function runs first! Tests will only be executed if it succeeds.
    * special test function `test::test_done`: If present, then this function runs last!
