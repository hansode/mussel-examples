#!/bin/bash

set -e
set -o pipefail
set -u

## validation

: "${security_group_id:?"should not be empty"}"

## main

output="$(
  mussel security_group destroy "${security_group_id}"
)"
{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2
