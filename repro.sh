#!/usr/bin/env bash
set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

>repro.log

msg() {
  echo "# $@" | tee -a repro.log >&2
}

cmd() {
  eval "$@" >>repro.log 2>&1
}

cleanup() {
  cmd rm -rf .bazelrc cache/repo
  cmd bazel clean --expunge
}
trap cleanup EXIT

check_cache() {
  cmd ls -R cache/repo && msg "    CACHE FOUND" || msg "    NO CACHE"
}

msg "Testing \`bazel build\`"

cleanup
msg "  Setting \`build --repository_cache\`"
echo "build --repository_cache=cache/repo" >.bazelrc
cmd bazel build //:bazel_sha256 --announce_rc
check_cache

cleanup
msg "  Setting \`fetch --repository_cache\`"
echo "fetch --repository_cache=cache/repo" >.bazelrc
cmd bazel build //:bazel_sha256 --announce_rc
check_cache

cleanup
msg "  Setting \`sync --repository_cache\`"
echo "sync --repository_cache=cache/repo" >.bazelrc
cmd bazel build //:bazel_sha256 --announce_rc
check_cache

msg "Testing \`bazel fetch\`"

cleanup
msg "  Setting \`build --repository_cache\`"
echo "build --repository_cache=cache/repo" >.bazelrc
cmd bazel fetch //:bazel_sha256 --announce_rc
check_cache

cleanup
msg "  Setting \`fetch --repository_cache\`"
echo "fetch --repository_cache=cache/repo" >.bazelrc
cmd bazel fetch //:bazel_sha256 --announce_rc
check_cache

cleanup
msg "  Setting \`sync --repository_cache\`"
echo "sync --repository_cache=cache/repo" >.bazelrc
cmd bazel fetch //:bazel_sha256 --announce_rc
check_cache

msg "Testing \`bazel sync\`"

cleanup
msg "  Setting \`build --repository_cache\`"
echo "build --repository_cache=cache/repo" >.bazelrc
cmd bazel sync --only=bazel_sha256 --announce_rc
check_cache

cleanup
msg "  Setting \`fetch --repository_cache\`"
echo "fetch --repository_cache=cache/repo" >.bazelrc
cmd bazel sync --only=bazel_sha256 --announce_rc
check_cache

cleanup
msg "  Setting \`sync --repository_cache\`"
echo "sync --repository_cache=cache/repo" >.bazelrc
cmd bazel sync --only=bazel_sha256 --announce_rc
check_cache
