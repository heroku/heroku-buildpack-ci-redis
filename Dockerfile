ARG BUILD_IMAGE
ARG RUNTIME_IMAGE

# Use the build image variant (eg heroku-18-build) which include headers/build tools.
FROM $BUILD_IMAGE as builder

ARG REDIS_VERSION

RUN mkdir -p /build /cache /env
RUN [ -z "${REDIS_VERSION}" ] || echo "${REDIS_VERSION}" > /env/REDIS_VERSION
COPY . /buildpack
# Sanitize the environment seen by the buildpack, to prevent reliance on
# environment variables that won't be present when it's run by Heroku CI.
RUN env -i PATH=$PATH HOME=$HOME /buildpack/bin/detect /build
RUN env -i PATH=$PATH HOME=$HOME /buildpack/bin/compile /build /cache /env

# Use the standard stack image for testing, to catch missing runtime dependencies.
FROM $RUNTIME_IMAGE

COPY --from=builder /build /app
WORKDIR /app
