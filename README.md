# Docker Login Buildkite Plugin [![Build status](https://badge.buildkite.com/26275954e05437ec7380e553bb83a515d70be2a0abf8f08815.svg?branch=master)](https://buildkite.com/buildkite/plugins-docker-login)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) to login to docker registries.

## Securing your password

To avoid leaking your docker password to buildkite.com or anyone with access to build logs, you need to avoid including it in pipeline.yml. This means it needs to be set specifically with an environment variable in an [Agent hook](https://buildkite.com/docs/agent/hooks), or made available from a previous plugin defined on the same step.

### Securing your credentials between Buildkite Jobs

By default, this plugin creates a step-specific docker config folder that gets removed after it is finished. If you want to disable that behaviour (for example, if you are using the Elastic CI Stack for AWS that already [creates a per-job `DOCKER_CONFIG` directory](https://github.com/buildkite/elastic-ci-stack-for-aws/pull/756)), you may also have to disable the plugin from logging out after it is finished or you may run into race conditions in multi-agent setups.

## Example

```bash
# environment or pre-command hook
export MY_DOCKER_LOGIN_PASSWORD=mysecretpassword
```

```yml
steps:
  - command: ./run_build.sh
    plugins:
      - docker-login#v3.0.0:
          username: myuser
          password-env: MY_DOCKER_LOGIN_PASSWORD
```

## Configurations

### Required

There is a single option required to configure and use this plugin.

#### `username`

The username to send to the docker registry.

### Optional

#### `disable-logout` (boolean, insecure)

Set to `true` if you don't want the plugin to execute a `docker logout` when the step is finished.

Note that doing so may be a security risk allowing interaction with a private repository to any script or person with access to the agent if the local docker daemon saves credentials in a local unencrypted store they have access to (as is the default behaviour).

#### `isolate-config` (boolean, insecure)

Set to `false` if you don't want the plugin to create a special docker configuration for the step.

Note that doing so may be a security risk unless you are doing something similar outside of this plugin due to the login credentials being a shared state among all agents and jobs run by them with access to the same docker daemon. This can cause jobs to fail intermmittently or even allow access to private repositories to jobs that shouldn't have such access.

It is safe to disable if you are using the [Elastic CI Stack for AWS 5.0.0 or later](https://github.com/buildkite/elastic-ci-stack-for-aws).

### `password-env`

The environment variable that the password is stored in.

Defaults to `DOCKER_LOGIN_PASSWORD`.

### `retries`

Retries login after a delay N times. Defaults to 0 (no retries).

### `server`

The server to log in to, if blank or ommitted logs into Docker Hub.

## Windows Issues

This plugin requires git-bash, not the Windows built-in bash.exe, so you'll need to set your system PATH to have git-bash bin directory first, normallly `C:\Program Files\git\bin`.

## License

MIT (see [LICENSE](LICENSE))
