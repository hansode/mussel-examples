# 改善案レポート

## 本件の目的

> mussel <resource> createに--output-format idオプションを導入し、スクリプト作成をしやすくする

これを実装し、「uuidを取得する為のパイプ、egrepコマンド、awkコマンドを削除」の効果を確認する。

## 新機能：「output filter」

https://github.com/axsh/wakame-vdc/tree/feature-mussel-filter-task

+ 【特徴】: musselの出力結果を最小化
   + HTTPメソッド毎に異なるフィルタ
      + `POST`: `:id:`のみ表示
      + `GET`: フィルタ無し状態, YAMLドキュメントがそのまま表示される
      + `PUT`: 出力無し or 新リソースuuidを表示
      + `DELETE`: 表示無し
+ 【使い方】: 環境変数`MUSSEL_OUTPUT_FORMAT`に`minimal`を指定
   + ~/.musselrcで指定しても良い
   + シェルスクリプト内で指定しても良い

## output filter 機能反映版スクリプト例


`~/.musselrc`:

```
$ cat ~/.musselrc
DCMGR_HOST=10.0.2.2
account_id=a-shpoolxx
```

`output-filter-feature-sample.sh`:

```
#!/bin/bash

set -e
set -o pipefail

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

## 実行結果例

> ```
> $ time ./output-filter-feature-sample.sh
> ```

![mussel-output-filter-demo](https://cloud.githubusercontent.com/assets/76867/8151379/f1e810ca-1346-11e5-8e0c-4ab63efc0d48.gif)

> ```
> $ time bash -x ./output-filter-feature-sample.sh
> ```

![mussel-output-filter-demo2](https://cloud.githubusercontent.com/assets/76867/8151404/7cc80f1a-1347-11e5-82dd-c4c6168a6b79.gif)

## ここまでのまとめ

+ 目標の1つだった「uuidを取得する為のパイプ、egrepコマンド、awkコマンドを削除」を達成

## 今後へ向けて

### mussel

+ output filter機能をmerge
+ wait-for機能実装作業
  + 次の目的は、「retry_until関数排除」
+ APIに対応してないコマンドをmusselで実装
  + 不要だからmusselで実装してないのか
  + 必要なのにmusselで実装してないのか
  + 選別する必要あり
  + APIリファレンス作成と同時並行するのが良さそうか

### API

+ API新レスポンス機能検討
+ `PUT`の整理?
   + 例えばinstance.backupは、新たなリソースを生成している
   + `PUT` -> `POST` へ切り替え検討(by unakatsuo)
      + 仮に切り替えるとしても、しばらくは互換性維持する必要あり
