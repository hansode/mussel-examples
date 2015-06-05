#!/bin/bash

set -e
set -o pipefail
set -u

## index

output="$(
  mussel ssh_key_pair index
)"

{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

##

echo "${output}" \
 | egrep :id: \
 | awk '{print $3}'
