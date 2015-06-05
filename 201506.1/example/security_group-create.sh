#!/bin/bash

set -e
set -o pipefail
set -u

## validation

: "${rule:?"should not be empty"}"

if ! [[ -f "${rule}" ]]; then
  echo "no such file: ${rule}" >&2
fi

## main

output="$(
  rule= \
  mussel security_group create \
   --rule "${rule}"
)"
{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

security_group_id="$(
  echo "${output}" \
  | egrep ^:id: \
  | awk '{print $2}'
)"
: "${security_group_id:?"should not be empty"}"

##

echo security_group_id="${security_group_id}"
