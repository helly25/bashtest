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

"""helly25_bashtest/bashtest:bashtest"""

load("@rules_shell//shell:sh_test.bzl", "sh_test")

def bashtest(
        name,
        deps = [],
        env = {},
        **kwargs):
    """Bashtest wrapper.

    Specialized `sh_shell` rule to simplify `bashtest` usage. The rule provides
    the `helly25_bashtest` environement variable that should
    be used in test scripts to source the `bashtest.sh` script as follows:

    * File: sh_test.sh

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

    * File: BUILD

    ```bzl
    load("@com_helly25_bashtest//bashtest:bashtest.bzl", "bashtest")

    bashtest(
        name = "sh_test",
        srcs = ["sh_test.sh"],
    )
    ```

    Args:
        name:      Name of the test rule. Should end in `_test`
        deps:      Dependencies which will have bashtest_sh automatically added.
        env:       Environmentname that automatically adds `helly25_bashtest`.
        **kwargs:  All other attributes are passed through as is.
    """

    # The module name is either 'helly25_bashtest' or 'com_helly25_bashtest'.
    # However, its workspace name is 'com_helly25_bashtest' and in Bazelmod mode we
    # use that as the repo_name, so it works in both cases.
    extra_env = {
        "helly25_bashtest": (
            "$(rootpath @com_helly25_bashtest//bashtest:bashtest_sh)"
        ),
    }
    sh_test(
        name = name,
        deps = deps + ["@com_helly25_bashtest//bashtest:bashtest_sh"],
        env = env | extra_env,
        **kwargs
    )
