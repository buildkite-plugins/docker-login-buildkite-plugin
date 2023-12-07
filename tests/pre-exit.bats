#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

# export DOCKER_STUB_DEBUG=/dev/tty

setup () {
    export BUILDKITE_DOCKER_LOGIN_TEMP_CONFIG="${BATS_TEST_TMPDIR}/test-folder"
}

@test "Clean logout execution" {
    stub docker \
      "echo got \$# args \$@"

    run "$PWD/hooks/pre-exit"

    assert_success
    assert_output --partial 'got 1 args logout'
    refute_output --partial "removing ${BUILDKITE_DOCKER_LOGIN_TEMP_CONFIG}"

    unstub docker
}

@test "Server can be set" {
    export BUILDKITE_PLUGIN_DOCKER_LOGIN_SERVER='my-server'

    stub docker \
      "echo got \$# args \$@"

    run "$PWD/hooks/pre-exit"

    assert_success
    assert_output --partial 'got 2 args logout my-server'

    unstub docker
}

@test "Docker config is removed if it exists" {
    mkdir "${BUILDKITE_DOCKER_LOGIN_TEMP_CONFIG}"
    
    stub docker \
      "echo got \$# args \$@"

    stub rm \
      "echo removing \$2"

    run "$PWD/hooks/pre-exit"

    assert_success
    assert_output --partial 'got 1 args logout'
    assert_output --partial "removing ${BUILDKITE_DOCKER_LOGIN_TEMP_CONFIG}"

    unstub docker
    unstub rm
}

@test "Can prevent from file to be removed" {
    mkdir "${BUILDKITE_DOCKER_LOGIN_TEMP_CONFIG}"
    export BUILDKITE_PLUGIN_DOCKER_LOGIN_ISOLATE_CONFIG='false'
    
    stub docker \
      "echo got \$# args \$@"

    run "$PWD/hooks/pre-exit"

    assert_success
    assert_output --partial 'got 1 args logout'
    refute_output --partial "removing ${BUILDKITE_DOCKER_LOGIN_TEMP_CONFIG}"

    unstub docker
}