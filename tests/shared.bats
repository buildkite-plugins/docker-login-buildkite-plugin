#!/usr/bin/env bats

load "${BATS_PLUGIN_PATH}/load.bash"

setup() {
  # shellcheck source=lib/shared.bash
  source "${PWD}/lib/shared.bash"
}

@test "Backoff delay stays within the ceiling for each attempt" {
  local -i ceiling=$BACKOFF_BASE_DELAY

  for attempt in 1 2 3 4 ; do
    for (( i = 0; i < 50; i++ )) ; do
      delay=$(calculate_backoff_delay "$attempt")
      (( delay >= 0 )) || fail "attempt ${attempt} returned negative delay ${delay}"
      (( delay <= ceiling )) || fail "attempt ${attempt} returned ${delay}, above ceiling ${ceiling}"
    done

    ceiling=$(( ceiling * 2 ))
  done
}

@test "Backoff delay is jittered rather than fixed" {
  local -i first
  local -i delay
  local spread=false

  first=$(calculate_backoff_delay 4)

  # Attempt 4 has a 16s ceiling, so 50 draws landing on one value would mean
  # the jitter isn't being applied.
  for (( i = 0; i < 50; i++ )) ; do
    delay=$(calculate_backoff_delay 4)

    if (( delay != first )) ; then
      spread=true
      break
    fi
  done

  [ "$spread" = true ] || fail "expected a spread of delays, every draw returned ${first}"
}

@test "Backoff delay is capped" {
  for attempt in 6 10 60 ; do
    for (( i = 0; i < 25; i++ )) ; do
      delay=$(calculate_backoff_delay "$attempt")
      (( delay >= 0 )) || fail "attempt ${attempt} returned negative delay ${delay}"
      (( delay <= BACKOFF_MAX_DELAY )) || fail "attempt ${attempt} returned ${delay}, above cap ${BACKOFF_MAX_DELAY}"
    done
  done
}
