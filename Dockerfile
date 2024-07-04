ARG BASE_IMAGE
FROM $BASE_IMAGE
USER root

ARG REDIS_VERSION
ARG REDIS_CI_TLS

RUN mkdir -p /app /cache /env
RUN [ -z "${REDIS_VERSION}" ] || echo "${REDIS_VERSION}" > /env/REDIS_VERSION
RUN [ -z "${REDIS_CI_TLS}" ] || echo "${REDIS_CI_TLS}" > /env/REDIS_CI_TLS
COPY . /buildpack
# Sanitize the environment seen by the buildpack, to prevent reliance on
# environment variables that won't be present when it's run by Heroku CI.
RUN env -i PATH=$PATH HOME=$HOME /buildpack/bin/detect /app
RUN env -i PATH=$PATH HOME=$HOME /buildpack/bin/compile /app /cache /env

WORKDIR /app
