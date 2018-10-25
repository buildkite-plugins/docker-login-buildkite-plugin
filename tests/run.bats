#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# export DOCKER_STUB_DEBUG=/dev/tty

@test "Login to to dockerhub" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_USERNAME="blah"
  export DOCKER_LOGIN_PASSWORD="llamas"

  stub docker \
    "login --username blah --password-stdin : echo logging in to docker hub" \
    "logout hub.docker.com : echo logging out of docker hub"

  run $PWD/hooks/pre-command

  assert_success
  assert_output --partial "logging in to docker hub"

  run $PWD/hooks/post-command

  assert_success
  assert_output --partial "logging out of docker hub"

  unstub docker
}

@test "Login to to single registry" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_USERNAME="blah"
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_SERVER="my.registry.blah"
  export DOCKER_LOGIN_PASSWORD="llamas"

  stub docker \
    "login --username blah --password-stdin my.registry.blah : echo logging in to my.registry.blah" \
    "logout my.registry.blah : echo logging out of my.registry.blah"

  run $PWD/hooks/pre-command

  assert_success
  assert_output --partial "logging in to my.registry.blah"

  run $PWD/hooks/post-command

  assert_success
  assert_output --partial "logging out of my.registry.blah"

  unstub docker
}

@test "Login to single registry with deprecated password" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_USERNAME="blah"
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_PASSWORD="llamas"

  stub docker \
    "login --username blah --password-stdin : echo logging in to docker hub"

  run $PWD/hooks/pre-command

  assert_success
  assert_output --partial "logging in to docker hub"
  assert_output --partial "The password property of the docker-login plugin has been deprecated"

  unstub docker
}

@test "Login to multiple registries" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_0_USERNAME="blah"
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_0_SERVER="my.registry.blah"
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_0_PASSWORD_ENV="DOCKER_LOGIN_PASSWORD1"
  export DOCKER_LOGIN_PASSWORD1="llamas"
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_1_USERNAME="blah"
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_1_PASSWORD_ENV="DOCKER_LOGIN_PASSWORD2"
  export DOCKER_LOGIN_PASSWORD2="alpacas"

  stub docker \
    "login --username blah --password-stdin my.registry.blah : echo logging in to my.registry.blah" \
    "login --username blah --password-stdin : echo logging in to docker hub"

  run $PWD/hooks/pre-command

  assert_success
  assert_output --partial "logging in to my.registry.blah"
  assert_output --partial "logging in to docker hub"

  unstub docker

  stub docker \
    "logout my.registry.blah : echo logging out of my.registry.blah" \
    "logout hub.docker.com : echo logging out of docker hub"

  run $PWD/hooks/post-command

  assert_success
  assert_output --partial "logging out of my.registry.blah"
  assert_output --partial "logging out of docker hub"

  unstub docker
}
