#!/bin/bash

set -e
set -o pipefail
set -u

# validation

: "${cpu_cores:?"should not be empty"}"
: "${hypervisor:?"should not be empty"}"
: "${memory_size:?"should not be empty"}"
: "${image_id:?"should not be empty"}"
: "${ssh_key_id:?"should not be empty"}"
: "${vifs:?"should not be empty"}"
display_name="${display_name:-"$(date +%Y%m%d%H%M%S)"}"

if ! [[ -f "${vifs}" ]]; then
  echo "no such file: ${vifs}" >&2
fi

## main

output="$(
  cpu_cores= \
  hypervisor= \
  image_id= \
  memory_size= \
  ssh_key_id= \
  vifs= \
  display_name= \
  mussel instance create \
   --cpu-cores    "${cpu_cores}"    \
   --hypervisor   "${hypervisor}"   \
   --image-id     "${image_id}"     \
   --memory-size  "${memory_size}"  \
   --ssh-key-id   "${ssh_key_id}"   \
   --vifs         "${vifs}"         \
   --display-name "${display_name}" \
)"
{
  echo "${output}"
} | sed "s,^,[S:${$}] ," >&2

instance_id="$(
  echo "${output}" \
  | egrep ^:id: \
  | awk '{print $2}'
)"
: "${instance_id:?"should not be empty"}"

## wait-for

{
  . ${BASH_SOURCE[0]%/*}/retry.sh
  retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: running")"' ]]
} 2>&1 | sed "s,^,[D:${$}] ," >&2

##

echo instance_id="${instance_id}"
