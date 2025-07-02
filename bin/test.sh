#!/usr/bin/env bash

set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: $0 STACK"; exit 1; }

STACK="${1}"
BASE_IMAGE="heroku/${STACK/-/:}-build"
OUTPUT_IMAGE="redis-test-${STACK}"

echo "Building buildpack on stack ${STACK}...with valkey version ${REDIS_VERSION}"

docker build \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    ${REDIS_VERSION:+--build-arg "REDIS_VERSION=${REDIS_VERSION}"} \
    -t "${OUTPUT_IMAGE}" \
    .

echo "Checking redis-server presence and version..."

# Redis <4 does not support connection URLs so REDIS_URL has to be parsed:
# https://stackoverflow.com/questions/38271281/can-i-use-redis-cli-with-a-connection-url
REDIS_CONNECTION_ARGS="\$(echo \${REDIS_URL} | sed 's_redis://\(.*\):\(.*\)@\(.*\):\(.*\)/_-h \3 -p \4 -a \2_')"
TEST_COMMAND="source .profile.d/valkey.sh && sleep 1 && valkey-cli ${REDIS_CONNECTION_ARGS} info server | grep valkey_version:${REDIS_VERSION:-}"
docker run --rm -t "${OUTPUT_IMAGE}" bash -c "${TEST_COMMAND}"

echo "Success!"
