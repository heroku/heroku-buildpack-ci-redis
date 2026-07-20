#!/usr/bin/env bash

set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: $0 STACK"; exit 1; }

STACK="${1}"
BASE_IMAGE="heroku/${STACK/-/:}-build"
OUTPUT_IMAGE="valkey-test-${STACK}"

echo "Building buildpack on stack ${STACK}...with valkey version ${VALKEY_VERSION:-default}"

docker build \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    ${VALKEY_VERSION:+--build-arg "VALKEY_VERSION=${VALKEY_VERSION}"} \
    -t "${OUTPUT_IMAGE}" \
    .

echo "Checking valkey-server presence and version..."

# Valkey's INFO reports a fixed compatibility redis_version; the real version
# is in the valkey_version field, so assert against that.
VALKEY_CONNECTION_ARGS="\$(echo \${VALKEY_URL} | sed 's_redis://:\(.*\)@\(.*\):\(.*\)/_-h \2 -p \3 -a \1_')"
TEST_COMMAND="source .profile.d/valkey.sh && sleep 1 && valkey-cli ${VALKEY_CONNECTION_ARGS} info | grep valkey_version:${VALKEY_VERSION:-}"
docker run --rm -t "${OUTPUT_IMAGE}" bash -c "${TEST_COMMAND}"

echo "Success!"
