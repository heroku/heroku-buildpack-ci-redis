ARG BUILD_IMAGE
ARG RUNTIME_IMAGE

# Use the build image variant (eg heroku-18-build) which include headers/build tools.
FROM $BUILD_IMAGE as builder

RUN mkdir -p /build /cache /env
COPY . /buildpack
RUN /buildpack/bin/detect /build
RUN /buildpack/bin/compile /build /cache /env

# Use the standard stack image for testing, to catch missing runtime dependencies.
FROM $RUNTIME_IMAGE

COPY --from=builder /build /app
WORKDIR /app
