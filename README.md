# Docker Login Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to login to docker registries.

## Securing your password

To avoid leaking your docker password to buildkite.com or anyone with access to build logs, you need to avoid including it in pipeline.yml. This means it needs to be set specifically with an environment variable in an [Agent hook](https://buildkite.com/docs/agent/hooks), for instance the environment hook.

The examples below show how to provide passwords for single and multiple registries.

## Example: Login to docker hub (or a single server)

```bash
# environment or pre-command hook
export BUILDKITE_PLUGIN_DOCKER_LOGIN_PASSWORD=mysecretpassword
```

```yml
steps:
  - command: ./run_build.sh
    plugins:
      docker-login#v1.1.0:
        username: myuser
```

## Example: Log in to multiple registries

```bash
# environment or pre-command hook
export BUILDKITE_PLUGIN_DOCKER_LOGIN_0_PASSWORD=mysecretpassword1
export BUILDKITE_PLUGIN_DOCKER_LOGIN_1_PASSWORD=mysecretpassword2
```

```yml
steps:
  - command: ./run_build.sh
    plugins:
      docker-login#v1.1.0:
        - server: my.private.registry
          username: myuser
        - server: another.private.registry
          username: myuser
```

## Options

### `username`

The username to send to the docker registry.

### `server` (optional)

The server to log in to, if blank or ommitted logs into Docker Hub.

## License

MIT (see [LICENSE](LICENSE))
