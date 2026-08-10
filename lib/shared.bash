#!/bin/bash

set -eu -o pipefail

BACKOFF_BASE_DELAY=2
BACKOFF_MAX_DELAY=30

# calculate_backoff_delay <attempt>
#
# Full jitter: a random delay between zero and an exponentially growing
# ceiling. Registries rate limit by source IP, so parallel jobs sharing an
# egress address all fail at the same instant. A fixed delay would just replay
# the same burst; spreading attempts across the whole window is what breaks
# them out of lockstep.
function calculate_backoff_delay() {
  local -i attempt="$1"
  local -i ceiling

  # 2^attempt overflows a signed 64-bit int well before this, and any attempt
  # this deep is pinned to the ceiling anyway.
  if (( attempt >= 16 )); then
    ceiling="${BACKOFF_MAX_DELAY}"
  else
    ceiling=$(( BACKOFF_BASE_DELAY * (2 ** (attempt - 1)) ))

    if (( ceiling > BACKOFF_MAX_DELAY )); then
      ceiling="${BACKOFF_MAX_DELAY}"
    fi
  fi

  echo $(( RANDOM % (ceiling + 1) ))
}

# retry <number-of-retries> [--with-stdin] <command...>
function retry() {
  local -r -i retries="$1"; shift
  local -i max_attempts=$((retries + 1))
  local -i attempt_num=1
  local -i delay
  local exit_code
  local stdin_value

  if [[ "$1" == "--with-stdin" ]]; then
    stdin_value=$(cat)
    shift
  fi

  while (( attempt_num <= max_attempts )); do
    set +e
    "$@" <<< "${stdin_value:-}"
    exit_code=$?
    set -e

    if [[ $retries -eq 0 ]] || [[ $exit_code -eq 0 ]]; then
      return $exit_code
    elif (( attempt_num == max_attempts )) ; then
      echo "Login failed after $attempt_num attempts" >&2
      return $exit_code
    else
      delay=$(calculate_backoff_delay "$attempt_num")
      echo "Login failed on attempt ${attempt_num} of ${max_attempts}. Trying again in ${delay} seconds..." >&2
      sleep "${delay}"
      attempt_num=$(( attempt_num + 1 ))
    fi
  done
}
