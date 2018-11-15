**Warning** this is an experimental buildpack and is provided as-is without any Test
promise of support.

# Heroku CI buildpack: Redis

This experimental [Heroku buildpack](http://devcenter.heroku.com/articles/buildpacks)
vendors Redis into the dyno. It is intended for use with Heroku CI or any
other environment where data retention is not important.

Please note that Redis will loose all data each time a dyno restarts.

## Usage

The first run of this buildpack will take a while as Redis is downloaded and
compiled. Thereafter the compiled version will be cached. Redis will start locally
and be available on `redis://127.0.0.1:6379` available in the `REDIS_URL` environment variable.

## Releasing a new version

Make sure you publish this buildpack in the buildpack registry

`heroku buildpacks:publish heroku/ci-redis master`
