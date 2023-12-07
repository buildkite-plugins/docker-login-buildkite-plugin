#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

# export DOCKER_STUB_DEBUG=/dev/tty

setup() {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_USERNAME="blah"
  export DOCKER_LOGIN_PASSWORD="llamas"
}

@test "Missing required parameter fails" {
  unset BUILDKITE_PLUGIN_DOCKER_LOGIN_USERNAME

  run "$PWD/hooks/pre-command"

  assert_failure
}

@test "Login to single registry with default password" {
  stub docker \
    "login --username blah --password-stdin : echo logging in to docker hub; cat"

  run "${PWD}/hooks/pre-command"

  assert_success
  assert_output --partial "logging in to docker hub"
  assert_output --partial "llamas"

  unstub docker
}

@test "Login to single registry with password-env" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_PASSWORD_ENV="CUSTOM_DOCKER_LOGIN_PASSWORD"
  export CUSTOM_DOCKER_LOGIN_PASSWORD="llamas2"

  stub docker \
    "login --username blah --password-stdin : echo logging in to docker hub; cat"

  run "${PWD}/hooks/pre-command"

  assert_success
  assert_output --partial "logging in to docker hub"
  assert_output --partial "llamas2"

  unstub docker
}

@test "Multiple retries not used if first command is successful" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_RETRIES=5

  stub docker \
    "login --username blah --password-stdin : echo logging in to docker hub; cat"

  run "${PWD}/hooks/pre-command"

  assert_success
  assert_output --partial "logging in to docker hub"
  assert_output --partial "llamas"

  unstub docker
}

@test "Multiple retries used until command is successful" {
  export BUILDKITE_PLUGIN_DOCKER_LOGIN_RETRIES=5

  stub docker \
    "login --username blah --password-stdin : exit 1" \
    "login --username blah --password-stdin : exit 1" \
    "login --username blah --password-stdin : echo logging in to docker hub; cat"

  run "${PWD}/hooks/pre-command"

  assert_success
  assert_output --partial "logging in to docker hub"
  assert_output --partial "llamas"

  unstub docker
}