ARG BUILD_IMAGE
ARG RUNTIME_IMAGE

FROM $BUILD_IMAGE as builder

ARG REDIS_VERSION

RUN mkdir -p /build /cache /env
COPY . /buildpack
RUN /buildpack/bin/detect /build
RUN /buildpack/bin/compile /build /cache /env


FROM $RUNTIME_IMAGE

COPY --from=builder /build /app
WORKDIR /app
# Emulates https://devcenter.heroku.com/articles/buildpack-api#profile-d-scripts
RUN echo 'for f in /app/.profile.d/*; do source $f; done' >> ~/.bashrc
