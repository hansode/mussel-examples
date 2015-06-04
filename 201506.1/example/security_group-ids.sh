#!/bin/bash

set -e
set -o pipefail
set -u

## shell params

service_type="${1:-std}"

## index

output="$(
  mussel security_group index --service-type ${service_type}
)"

{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

##

echo "${output}" \
 | egrep :id: \
 | awk '{print $3}'
