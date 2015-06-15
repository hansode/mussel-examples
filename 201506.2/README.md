# 改善案レポート

https://github.com/axsh/wakame-vdc/tree/feature-mussel-filter-task

+ 【特徴】: musselの出力結果を最小化
+ 【使い方】: 環境変数`MUSSEL_OUTPUT_FORMAT`に`minimal`を指定

## output filter 機能反映版スクリプト

~/.musselrc:

```
$ cat ~/.musselrc
DCMGR_HOST=10.0.2.2
account_id=a-shpoolxx
```

sample:

```
#!/bin/bash

set -e
set -o pipefail
set -x

#
export MUSSEL_CALLER= # make sure to set empty
export MUSSEL_OUTPUT_FORMAT=minimal

#
keyname="mykeypair.${$}"
ssh-keygen -N "" -f "${keyname}"
ssh_key_id="$(
  mussel ssh_key_pair create \
   --public-key   "${keyname}.pub" \
)"

#
cat <<EOS > sgrule.txt
icmp:-1,-1,ip4:0.0.0.0/0
tcp:22,22,ip4:0.0.0.0/0
EOS
security_group_id="$(
  mussel security_group create \
   --rule          sgrule.txt
)"

#
cat <<EOS > vifs.json
{
 "eth0":{"network":"nw-demo1","security_groups":"${security_group_id}"}
}
EOS
instance_id="$(
  mussel instance create \
   --cpu-cores     1              \
   --hypervisor    kvm            \
   --image-id      wmi-centos1d64 \
   --memory-size   512            \
   --ssh-key-id    ${ssh_key_id}  \
   --vifs          vifs.json      \
)"

#

function retry_until() {
  local blk="$@"

  local wait_sec=${RETRY_WAIT_SEC:-120}
  local sleep_sec=${RETRY_SLEEP_SEC:-3}
  local tries=0
  local start_at=$(date +%s)
  local chk_cmd=

  while :; do
    eval "${blk}" && {
      break
    } || {
      sleep ${sleep_sec}
    }

    tries=$((${tries} + 1))
    if [[ "$(($(date +%s) - ${start_at}))" -gt "${wait_sec}" ]]; then
      echo "Retry Failure: Exceed ${wait_sec} sec: Retried ${tries} times" >&2
      return 1
    fi
    echo [$(date +%FT%X) "#$$"] time:${tries} "eval:${chk_cmd}" >&2
  done
}

retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: running")"' ]]

ipaddr="$(
  mussel instance show "${instance_id}" \
  | egrep ":address:" \
  | awk '{print $2}'
)"

retry_until "ping -c 1 -W 3 ${ipaddr}    >/dev/null"
retry_until "nc -w 3 ${ipaddr} 22 <<< '' >/dev/null"

ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -i "${keyname}" root@${ipaddr} hostname

# cleanup
mussel instance       destroy "${instance_id}"
# if instance is not terminated, destroying security_group and ssh_key_pair will be failed.
retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: terminated")"' ]]

mussel security_group destroy "${security_group_id}"
mussel ssh_key_pair   destroy "${ssh_key_id}"

rm -f sgrule.txt
rm -f vifs.json
rm -f "${keyname}" "${keyname}.pub"
```

## ここまでのまとめ

+ 目標の1つだった「uuidを取得する為のパイプ、egrepコマンド、awkコマンドを削除」を達成

## 今後へ向けて

### mussel

+ output filter機能をmerge
+ wait-for機能実装作業
  + 次の目的は、「retry_until関数排除」

### API

+ API新レスポンス機能検討
