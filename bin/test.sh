#!/usr/bin/env bash

set -euo pipefail

[ $# -eq 1 ] || { echo "Usage: $0 STACK"; exit 1; }

STACK="${1}"
BASE_IMAGE="heroku/${STACK/-/:}-build"
OUTPUT_IMAGE="redis-test-${STACK}"
REDIS_CI_TLS=${REDIS_CI_TLS:-}

echo "Building buildpack on stack ${STACK}...with redis version ${REDIS_VERSION}"

docker build \
    --no-cache \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    ${REDIS_VERSION:+--build-arg "REDIS_VERSION=${REDIS_VERSION}"} \
    ${REDIS_CI_TLS:+--build-arg "REDIS_CI_TLS=${REDIS_CI_TLS}"} \
    -t "${OUTPUT_IMAGE}" \
    .

echo "Checking redis-server presence and version..."

if [ -n "$REDIS_CI_TLS" ]; then
    REDIS_TLS_ARGS="--tls --insecure"
else
    REDIS_TLS_ARGS=""
fi

# Redis <4 does not support connection URLs so REDIS_URL has to be parsed:
# https://stackoverflow.com/questions/38271281/can-i-use-redis-cli-with-a-connection-url
REDIS_CONNECTION_ARGS="\$(echo \${REDIS_URL} | sed 's_rediss\{0,1\}://\(.*\):\(.*\)@\(.*\):\(.*\)/_-h \3 -p \4 -a \2_')"
TEST_COMMAND="source .profile.d/redis.sh && sleep 1 && redis-cli ${REDIS_TLS_ARGS} ${REDIS_CONNECTION_ARGS} info | grep redis_version:${REDIS_VERSION:-}"
docker run --rm -t "${OUTPUT_IMAGE}" bash -c "${TEST_COMMAND}"

echo "Success!"
