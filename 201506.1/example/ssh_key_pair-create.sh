#!/bin/bash

set -e
set -o pipefail
set -u

## validation

: "${public_key:?"should not be empty"}"
display_name="${display_name:-"${public_key}"}"

if ! [[ -f "${public_key}" ]]; then
  echo "no such file: ${public_key}" >&2
fi

##

output="$(
  public_key= \
  display_name= \
  mussel ssh_key_pair create \
   --public-key "${public_key}" \
   --display-name "${display_name}"
)"
{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

ssh_key_id="$(
  echo "${output}" \
  | egrep ^:id: \
  | awk '{print $2}'
)"
: "${ssh_key_id:?"should not be empty"}"

##

echo ssh_key_id="${ssh_key_id}"
