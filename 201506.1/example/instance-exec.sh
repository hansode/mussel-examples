#!/bin/bash
#
# Usage:
#  $0 instance_id
#
set -e
set -o pipefail
set -u

## validation

: "${ssh_user:?"should not be empty"}"
: "${private_key:?"should not be empty"}"
: "${instance_id:?"should not be empty"}"

if ! [[ -f "${private_key}" ]]; then
  echo "no such file: ${private_key}" >&2
fi

## main

output="$(
  mussel instance show "${instance_id}"
)"
{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

ipaddr="$(
  echo "${output}" \
  | egrep -w :address: \
  | awk '{print $2}'
)"
: "${ipaddr:?"should not be empty"}"

## ssh to the instance

chmod 600 "${private_key}"
ssh \
 -o 'StrictHostKeyChecking no' \
 -o 'UserKnownHostsFile /dev/null' \
 -i "${private_key}" \
 "${ssh_user}@${ipaddr}" "${@}"
