#!/bin/bash

set -e
set -o pipefail
set -u

## validation

: "${instance_id:?"should not be empty"}"

## main

output="$(
  mussel instance destroy "${instance_id}"
)"
{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

## wait-for

{
  . ${BASH_SOURCE[0]%/*}/retry.sh
  retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: terminated")"' ]]
} 2>&1 | sed "s,^,[D:${$}] ," >&2
