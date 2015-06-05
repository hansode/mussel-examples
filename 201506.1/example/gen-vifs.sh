#!/bin/bash

set -e
set -o pipefail
set -u

## validation

: "${vifs:?"should not be empty"}"
: "${network_id:?"should not be empty"}"
: "${security_group_id:?"should not be empty"}"

##

cat <<EOS | tee "${vifs}" | sed "s,^,[D:${$}] ," >&2
{
 "eth0":{"network":"${network_id}","security_groups":"${security_group_id}"}
}
EOS

##

echo vifs="${vifs}"
