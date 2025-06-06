#!/usr/bin/env bash

# SPDX-FileCopyrightText: Copyright (c) The helly25 authors (helly25.com)
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# shellcheck disable=SC2317 # Functions are called bashtest

set -euo pipefail

# shellcheck disable=SC1090,SC1091,SC2154
source "${helly25_bashtest}"

bad_bashtest() {
    echo >&2 "FATAL: Test functionality broken: ${*}"
    exit 1
}

_DONE_CALLED=0
_INIT_CALLED=0

test::test_init() {
    echo "Hello World of tests."
    _INIT_CALLED=1
    return 1
}

test::test_done() {
    echo "The world is ending."
    _DONE_CALLED=1
}

test::test_1() {
    return 1
}

test::test_2() {
    return 1
}

test::test_3() {
    return 1
}

test_runner && bad_bashtest "Test was meant to fail but did not."

[[ "${_INIT_CALLED}" == "1" ]] || bad_bashtest "Test init (test::test_init) was not called."
[[ "${_DONE_CALLED}" == "1" ]] || bad_bashtest "Test done (test::test_done) was not called."

[[ "${_BASHTEST_NUM_PASS}" == "0" ]] || bad_bashtest "Test has unexpected _BASHTEST_NUM_PASS."
[[ "${_BASHTEST_NUM_FAIL}" == "0" ]] || bad_bashtest "Test has unexpected _BASHTEST_NUM_FAIL."
[[ "${_BASHTEST_NUM_SKIP}" == "3" ]] || bad_bashtest "Test has unexpected _BASHTEST_NUM_SKIP."
[[ "${_BASHTEST_INIT_FAILED}" == "1" ]] || bad_bashtest "Test has unexpected _BASHTEST_INIT_FAILED."
[[ "${_BASHTEST_DONE_FAILED}" == "0" ]] || bad_bashtest "Test has unexpected _BASHTEST_DONE_FAILED."
