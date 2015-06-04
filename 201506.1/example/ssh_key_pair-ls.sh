#!/bin/bash

set -e
set -o pipefail
set -u

## shell params

ssh_key_pair_ids="${@:-""}"
service_type="std"

## main

fmt='%-12s %-19s %-6s %-47s %s\n'
printf "${fmt}" KEYPAIR CREATED TYPE FINGERPRINT NAME

if [[ -n "${ssh_key_pair_ids}" ]]; then
  output="${ssh_key_pair_ids}"
else
  output="$(${BASH_SOURCE[0]%/*}/ssh_key_pair-ids.sh "${service_type}")"
fi

for uuid in ${output}; do
        output="$(mussel ssh_key_pair show "${uuid}")"
    created_at="$(egrep "^:created_at:"      <<< "${output}" | cut -d' ' -f2-3)"; created_at="${created_at/ /T}"; created_at="${created_at%%.*}"
          type="$(egrep  ":service_type:"    <<< "${output}" | awk '{print $2}')"
  display_name="$(egrep "^:display_name:"    <<< "${output}" | cut -d' ' -f2-)"
  finger_print="$(egrep "^:finger_print:"    <<< "${output}" | cut -d' ' -f2-)"

  printf "${fmt}" "${uuid}" "${created_at}" "${type}" "${finger_print}" "\"${display_name}\""
done
