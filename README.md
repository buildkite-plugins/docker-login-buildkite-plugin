# Docker Login Buildkite Plugin [![Build status](https://badge.buildkite.com/26275954e05437ec7380e553bb83a515d70be2a0abf8f08815.svg?branch=master)](https://buildkite.com/buildkite/plugins-docker-login)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to login to docker registries.

## Securing your password

To avoid leaking your docker password to buildkite.com or anyone with access to build logs, you need to avoid including it in pipeline.yml. This means it needs to be set specifically with an environment variable in an [Agent hook](https://buildkite.com/docs/agent/hooks), or made available from a previous plugin defined on the same step.

## Example

```bash
# environment or pre-command hook
export MY_DOCKER_LOGIN_PASSWORD=mysecretpassword
```

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - docker-login#v2.0.1:
          username: myuser
          password-env: MY_DOCKER_LOGIN_PASSWORD
```

## Options

### `username`

The username to send to the docker registry.

### `server` (optional)

The server to log in to, if blank or ommitted logs into Docker Hub.

### `password-env`

The environment variable that the password is stored in.

Defaults to `DOCKER_LOGIN_PASSWORD`.

## License

MIT (see [LICENSE](LICENSE))
