#!/bin/bash

set -e
set -o pipefail
set -u

## shell params

security_group_ids="${@:-""}"
service_type="std"

## main

fmt='%-11s %-19s %-6s %-8s %s\n'
printf "${fmt}" SECURITYGRP CREATED TYPE NAME RULE

if [[ -n "${security_group_ids}" ]]; then
  output="${security_group_ids}"
else
  output="$(${BASH_SOURCE[0]%/*}/security_group-ids.sh "${service_type}")"
fi

for uuid in ${output}; do
        output="$(mussel security_group show "${uuid}")"
    created_at="$(egrep "^:created_at:"      <<< "${output}" | cut -d' ' -f2-3)"; created_at="${created_at/ /T}"; created_at="${created_at%%.*}"
          type="$(egrep  ":service_type:"    <<< "${output}" | awk '{print $2}')"
  display_name="$(egrep "^:display_name:"    <<< "${output}" | cut -d' ' -f2-)"
          set +e
          rule="$(egrep '^  [^:]'  <<< "${output}" | sed 's,^ *,,' | tr '\n' ' ')"; rule="${rule%% }"
          set -e
  printf "${fmt}" "${uuid}" "${created_at}" "${type}" "\"${display_name}\"" "\"${rule}\""
done
