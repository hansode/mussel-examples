#!/bin/bash

set -e
set -o pipefail
set -u

## validation

: "${instance_id:?"should not be empty"}"

## get the instance's ipaddress

output="$(
  mussel instance show "${instance_id}" \
)"
{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

ipaddr="$(
  echo "${output}" \
  | egrep ":address:" \
  | awk '{print $2}' \
  | tr '\n' ','
)"
ipaddr="${ipaddr%%,}" # remove tail ","
: "${ipaddr:?"should not be empty"}"

## wait-for

{
  . ${BASH_SOURCE[0]%/*}/retry.sh
  retry_until "ping -c 1 -W 3 ${ipaddr}"
  retry_until "nc ${ipaddr} 22 <<< ''"
} 2>&1 | sed "s,^,[D:${$}] ," >&2
