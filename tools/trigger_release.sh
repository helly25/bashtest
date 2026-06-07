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

set -euo pipefail

function die() { echo "ERROR: ${*}" 1>&2 ; exit 1; }

function usage() {
    cat <<EOF
Usage: ${0} [--dry-run] <command> <version>

<version> is the released version, i.e. the version currently present in
MODULE.bazel and CHANGELOG.md.

Commands:
  tag       Create and push the signed release tag for <version>.
  bump      Open a PR that bumps <version> to the next patch version. Use this
            on its own to recover when 'tag' succeeded but the bump did not.
  release   Run 'tag' then 'bump' (the full release flow).

Options:
  --dry-run, --dry, --dry-mode   Print the mutating actions instead of
                                 performing them. Read-only validations still
                                 run, but failing preconditions are downgraded
                                 to warnings so the full flow can be previewed.
  -h, --help                     Show this help and exit.
EOF
}

DRY_RUN=0
COMMAND=""
VERSION=""
for arg in "${@}"; do
    case "${arg}" in
        --dry-run|--dry|--dry-mode) DRY_RUN=1 ;;
        -h|--help) usage; exit 0 ;;
        -*) usage 1>&2; die "Unknown flag: '${arg}'." ;;
        *)
            if [[ -z "${COMMAND}" ]]; then
                COMMAND="${arg}"
            elif [[ -z "${VERSION}" ]]; then
                VERSION="${arg}"
            else
                usage 1>&2; die "Unexpected argument: '${arg}'."
            fi
            ;;
    esac
done

case "${COMMAND}" in
    tag|bump|release) ;;
    "") usage 1>&2; die "Must provide a command (tag|bump|release)." ;;
    *) usage 1>&2; die "Unknown command: '${COMMAND}'." ;;
esac

[[ -n "${VERSION}" ]] || { usage 1>&2; die "Must provide a version argument."; }

# Runs a mutating command, or just prints it when in dry-run mode.
function run() {
    if [[ ${DRY_RUN} == 1 ]]; then
        echo "DRY-RUN: ${*}" 1>&2
    else
        "${@}"
    fi
}

# Fails a precondition. In dry-run mode this is downgraded to a warning so the
# rest of the flow can still be previewed.
function check_fail() {
    if [[ ${DRY_RUN} == 1 ]]; then
        echo "WARNING (ignored in dry-run): ${*}" 1>&2
    else
        die "${*}"
    fi
}

# Validates the working tree and version consistency, and sets the global
# BAZELMOD_VERSION, CHANGELOG_VERSION and NEXT_VERSION.
function validate() {
    git fetch origin main  # Make sure the below is relevant.

    if [[ -n "$(git status --porcelain)" ]]; then
        # Non empty output means non clean branch.
        check_fail "Must be run from clean 'main' branch."
    fi
    if [[ -n "$(git diff origin/main --numstat)" ]]; then
        check_fail "Must be run from clean 'main' branch."
    fi
    if [[ -n "$(git diff origin/main --cached --numstat)" ]]; then
        check_fail "Must be run from clean 'main' branch."
    fi

    BAZELMOD_VERSION="$(sed -rne 's,.*version = "([0-9]+([.][0-9]+)+.*)".*,\1,p' < MODULE.bazel|head -n1)"
    CHANGELOG_VERSION="$(sed -rne 's,^# ([0-9]+([.][0-9]+)+.*)$,\1,p' < CHANGELOG.md|head -n1)"
    NEXT_VERSION="$(echo "${VERSION}"|awk -F. '/^(0|[1-9][0-9]*)([.](0|[1-9][0-9]*)){2,}([-+]|$)/{print $1"."$2"."(($3)+1)}')"

    if [[ "${BAZELMOD_VERSION}" != "${CHANGELOG_VERSION}" ]]; then
        check_fail "MODULE.bazel (${BAZELMOD_VERSION}) != CHANGELOG.md (${CHANGELOG_VERSION})."
    fi

    if [[ "${VERSION}" != "${BAZELMOD_VERSION}" ]]; then
        check_fail "Provided version argument (${VERSION}) different from merged version (${BAZELMOD_VERSION})."
    fi

    if [[ -z "${NEXT_VERSION}" ]]; then
        die "Could not determine next version from input (${VERSION})."
    fi
}

# Replaces the first `version = "${VERSION}"` in MODULE.bazel with the next
# version. Portable (no GNU-only `sed -i` / `0,/re/` address).
function bump_module_version() {
    if [[ ${DRY_RUN} == 1 ]]; then
        echo "DRY-RUN: bump MODULE.bazel version '${VERSION}' -> '${NEXT_VERSION}'." 1>&2
        return
    fi
    awk -v old="${VERSION}" -v new="${NEXT_VERSION}" '
        !done && index($0, "version = \"" old "\"") {
            sub("version = \"" old "\"", "version = \"" new "\"")
            done = 1
        }
        { print }
    ' MODULE.bazel > MODULE.bazel.tmp && mv MODULE.bazel.tmp MODULE.bazel
}

# Prepends a new (empty) changelog section for the next version. Portable.
function prepend_changelog() {
    if [[ ${DRY_RUN} == 1 ]]; then
        echo "DRY-RUN: prepend section '# ${NEXT_VERSION}' to CHANGELOG.md." 1>&2
        return
    fi
    { printf '# %s\n\n' "${NEXT_VERSION}"; cat CHANGELOG.md; } > CHANGELOG.md.tmp \
        && mv CHANGELOG.md.tmp CHANGELOG.md
}

# Creates and pushes the signed release tag for ${VERSION}.
function do_tag() {
    if git tag -l | grep -qFx "${VERSION}"; then
        check_fail "Version tag '${VERSION}' is already in use."
    fi
    run git tag -s -a "${VERSION}" \
        -m "New release tag version: '${VERSION}'." \
        -m "$(awk '/^#/{if(NR>1)exit}/^[^#]/{print}' <CHANGELOG.md)"
    run git push origin --tags
}

# Opens a PR that bumps ${VERSION} to ${NEXT_VERSION}.
function do_bump() {
    echo "Next version: ${NEXT_VERSION}"

    bump_module_version
    prepend_changelog

    local next_branch="chore/bump_version_to_${NEXT_VERSION}"

    run git checkout -b "${next_branch}"
    run git add MODULE.bazel
    run git add CHANGELOG.md
    run git commit -m "Bump version to ${NEXT_VERSION}"
    run git push -u origin "${next_branch}"
    run git push

    if ! which gh >/dev/null; then
        echo "WARNING: 'gh' not found; created branch '${next_branch}' but no PR." 1>&2
        return
    fi

    local bump_text="Bump version from ${VERSION} to ${NEXT_VERSION}"
    local merge_title="${bump_text}"
    local merge_subject="${bump_text}"
    local merge_body="Auto approved version bump from ${VERSION} to ${NEXT_VERSION} by trigger script."

    if [[ ${DRY_RUN} == 1 ]]; then
        echo "DRY-RUN: create PR '${merge_title}', mark ready, approve, and admin-merge branch '${next_branch}'." 1>&2
        return
    fi

    local prnum=""
    local prurl=""
    if gh pr create --title "${merge_title}" -b "Created by ${0}." 2>&1 | tee pr_create_output.txt; then
        prnum="$(sed -rne 's,https?://github.com/[^/]+/[^/]+/pull/([0-9]+)$,\1,p' < pr_create_output.txt)"
        prurl="$(sed -rne 's,https?://github.com/[^/]+/[^/]+/pull/([0-9]+)$,\0,p' < pr_create_output.txt)"
    else
        echo "ERROR: Cannot create PR:"
        cat pr_create_output.txt
    fi
    if [[ "${prnum}" -gt 1 ]]; then
        gh pr ready "${next_branch}"
        gh pr review "${next_branch}" -a -b "${merge_body}" || true
        if gh pr merge "${next_branch}" --admin -d -s -b "${merge_body}" -t "${merge_subject}"; then
            git checkout main
            git branch -d "${next_branch}"
            echo "PR ${prnum} was merged via admin override. See: ${prurl}."
        else
            gh pr merge "${next_branch}" --auto -d -s -b "${merge_body}" -t "${merge_subject}"
            git checkout main
            git branch -d "${next_branch}" || true
            echo "PR ${prnum} cannot be merged via admin override."
            echo "Please approve it at ${prurl}."
        fi
    fi
}

validate

case "${COMMAND}" in
    tag)     do_tag ;;
    bump)    do_bump ;;
    release) do_tag; do_bump ;;
esac
