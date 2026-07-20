**Warning** this is an experimental buildpack and is provided as-is without any
promise of support.

# Heroku CI buildpack: Valkey

This experimental [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks)
vendors [Valkey](https://valkey.io/) into the dyno. It is intended for use with
Heroku CI or any other environment where data retention is not important.

Please note that Valkey will lose all data each time a dyno restarts.

Valkey is a drop-in replacement for Redis and speaks the same protocol, so the
connection URL is exposed as both `VALKEY_URL` and `REDIS_URL`.

## Usage

The first run of this buildpack will take a while as Valkey is downloaded and
compiled. Thereafter the compiled version will be cached. Valkey will start
locally on `redis://127.0.0.1:6379`, available in both the `VALKEY_URL` and
`REDIS_URL` environment variables.

By default Valkey 8 is used. You can specify a `VALKEY_VERSION` in the `env`
section of your
[app.json](https://devcenter.heroku.com/articles/heroku-ci#environment-variables-env-key)
to select a supported major (`7.2`, `8`, or `9`) or an exact version (e.g.
`8.1.8`). For backward compatibility, `REDIS_VERSION` is also honored when
`VALKEY_VERSION` is not set. Versions older than 7.2 are no longer supported and
fall back to 7.2. This feature is experimental and subject to change.

## Releasing a new version

Make sure you publish this buildpack in the buildpack registry

`heroku buildpacks:publish heroku/ci-redis master`
