#!/usr/bin/env bash

__DIR__="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# required libs
source "${__DIR__}/.bash/functions.shlib"

set -E
trap 'throw_exception' ERR

usage() {
cat <<EOF
Usage: ${0##*/} OPTIONS
test role

    -h          display this help and exit
    -i STRING   target host to run against (default: 127.0.0.1)
    -u STRING   connect as this user (default: current user)
EOF
}

OPTIND=1

while getopts "hi:u:" opt; do
  case "${opt}" in
    h )
      usage
      exit 0
      ;;
    i )
      TARGET_HOST="${OPTARG}"
      ;;
    u )
      CONNECT_USER="${OPTARG}"
      ;;
    '?' )
      usage >&2
      exit 1
      ;;
  esac
done
shift "$((OPTIND-1))"

if [[ -z "${TARGET_HOST}" ]]; then
  TARGET_HOST="127.0.0.1"
  CONNECTION="local"
fi

if [[ -z "${CONNECT_USER}" ]]; then
  CONNECT_USER="$(whoami)"
fi

if [[ -z "${CONNECTION}" ]]; then
  CONNECTION="smart"
fi

role_root="$(pwd)"

consolelog "installing requirements"
ansible-galaxy install lifeofguenter.oracle-java

consolelog "running role as playbook #1"
ansible-playbook \
  --inventory="${TARGET_HOST}," \
  --user="${CONNECT_USER}" \
  --extra-vars="role_root=${role_root}" \
  --connection="${CONNECTION}" \
  tests/test.yml

consolelog "running role as playbook #2"
ansible-playbook \
  --inventory="${TARGET_HOST}," \
  --user="${CONNECT_USER}" \
  --extra-vars="role_root=${role_root}" \
  --connection="${CONNECTION}" \
  tests/test.yml

# waitfor 5min
while [[ "${i}" -lt "60" ]]; do
  i="$((i + 1))"
  if ! curl \
    --head \
    --silent \
    --fail \
    --show-error \
    "${TARGET_HOST}:8080" 2> /dev/null; then
    consolelog "waitfor ${TARGET_HOST}:8080 #${i}"
    sleep 5
  else
    success="1"
    break
  fi
done

if [[ -z "${success}" ]]; then
  consolelog "wildfly unreachable" "error"
  exit 1
fi
