#!/bin/bash

set -e
set -o pipefail
set -u

## shell params

: "${ssh_key_id:?"should not be empty"}"

## main

{
  mussel ssh_key_pair destroy "${ssh_key_id}"
} | sed "s,^,[S:${$}] ," >&2
