#!/bin/bash

set -e
set -o pipefail
set -u

## shell params

state="${1:-alive}"

## main

output="$(
  mussel instance index --state "${state}" \
)"
{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

##

echo "${output}" \
 | egrep :id: \
 | awk '{print $3}'
