#!/usr/bin/env bash

set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: $0 STACK"; exit 1; }

STACK="${1}"
BASE_IMAGE="heroku/${STACK/-/:}-build"
OUTPUT_IMAGE="redis-test-${STACK}"

echo "Building buildpack on stack ${STACK}..."

docker build \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    ${REDIS_VERSION:+--build-arg "REDIS_VERSION=${REDIS_VERSION}"} \
    -t "${OUTPUT_IMAGE}" \
    .

echo "Checking redis-server presence and version..."

# Redis <4 does not support connection URLs so REDIS_URL has to be parsed:
# https://stackoverflow.com/questions/38271281/can-i-use-redis-cli-with-a-connection-url
REDIS_CONNECTION_ARGS="\$(echo \${REDIS_URL} | sed 's_redis://h:\(.*\)@\(.*\):\(.*\)/_-h \2 -p \3 -a \1_')"
TEST_COMMAND="source .profile.d/redis.sh && sleep 1 && redis-cli ${REDIS_CONNECTION_ARGS} info | grep redis_version:${REDIS_VERSION:-}"
docker run --rm -it "${OUTPUT_IMAGE}" bash -c "${TEST_COMMAND}"

echo "Success!"
