
# Returns a list of config prefixes of servers
plugin_var_prefixes() {
  while IFS='=' read -r name _ ; do
    if [[ $name =~ ^(BUILDKITE_PLUGIN_DOCKER_LOGIN_[0-9]+) || $name =~ ^(BUILDKITE_PLUGIN_DOCKER_LOGIN)_[^0-9] ]] ; then
      echo "${BASH_REMATCH[1]}"
    fi
  done < <(compgen -e) | sort | uniq
}
