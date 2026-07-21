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
# is in the valkey_version field, so assert against that. The URLs carry an
# empty username (redis://:pw@) to match Heroku Key-Value Store, but
# valkey-cli -u would then send AUTH "" pw and fail, so extract the user and
# password and pass them as flags: --user only when the URL names one (v9's
# heroku ACL user), -a always. Both URLs are checked.
CHECK='check() { url="$1"; user="${url#*://}"; user="${user%%:*}"; pw="${url%%@*}"; pw="${pw##*:}"; \
  valkey-cli ${user:+--user "$user"} -a "$pw" info; }'
TEST_COMMAND="source .profile.d/valkey.sh && sleep 1 && ${CHECK} \
  && check \"\${VALKEY_URL}\" | grep valkey_version:${VALKEY_VERSION:-} \
  && check \"\${REDIS_URL}\" | grep valkey_version:${VALKEY_VERSION:-}"
docker run --rm -t "${OUTPUT_IMAGE}" bash -c "${TEST_COMMAND}"

echo "Success!"
