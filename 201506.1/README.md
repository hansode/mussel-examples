# 改善案レポート

## 目的

musselによる基本リソース操作機能とユーティリティコマンドの組み合せにより、インスタンス起動からSSHログインまでを行う。それにより改善点を洗い出す。

## インスタンスを起動するには、事前にリソースを作成しておく必要がある。

1. SSHキーペア
2. セキュリティグループ(今回はSSH接続する必要があるので必要)

## SSHキーペア

公開鍵を登録するには、キーペアを生成する必要がある。

```
$ ssh-keygen -N "" -f mykeypair
# => mykeypair mykeypair.pub
```

生成されたキーペアのうち公開鍵を登録する。

```
$ mussel ssh_key_pair create \
   --public-key mykeypair.pub
# => ssh-xxxxxxxx
```

## セキュリティグループ

セキュリティグループルールファイルを作成する。疎通確認用にicmpと、ssh用にtcp:22を許可する。

```
$ cat sgrule.txt
icmp:-1,-1,ip4:0.0.0.0/0
tcp:22,22,ip4:0.0.0.0/0
```

ルールファイルを登録する。

```
$ mussel security_group create \
   --rule sgrule.txt
# => sg-xxxxxxxx
```

## vifs.json

次にインスタンス作成。通信するには1つ以上のVIFが必要となるので、vifs.jsonを作成する必要がある。この時、事前に生成したセキュリティグループのuuidを指定する必要がある。この時、ネットワーク設定は既に完了しているものとする。今回はnw-demo1を指定する。

```
$ cat vifs.json
{
 "eth0":{"network":"nw-demo1","security_groups":"sg-xxxxxxxx"}
}
```

## インスタンス作成

これまでに生成したvifs.jsonとssh-xxxxxxxxを指定し、インスタンスを生成する。

```
$ mussel instance create \
   --cpu-cores    1              \
   --hypervisor   kvm            \
   --image-id     wmi-centos1d64 \
   --memory-size  512            \
   --ssh-key-id   ssh-xxxxxxxx   \
   --vifs         vifs.json
# => i-xxxxxxxx
```

生成直後は、生成予約したに過ぎず、インスタンスは生成されていない。生成完了しているかどうかを判断するには、インスタンスの状態を確認する必要がある。作成完了状態とは、runningである。状態を確認し、runningになるまで何回か繰り返す必要がある。

```
$ mussel instance show i-xxxxxxxx | egrep ^:state:
# => :state: scheduling
$ mussel instance show i-xxxxxxxx | egrep ^:state:
# => :state: scheduling
$ mussel instance show i-xxxxxxxx | egrep ^:state:
# => :state: scheduling
$ mussel instance show i-xxxxxxxx | egrep ^:state:
# => :state: running
```

runningは、まだ電源がONになっただけである。

## 疎通確認

SSHするにはIPアドレスを知る必要がある。

```
$ mussel instance show i-xxxxxxxx | egrep ":address:" | awk '{print $2}'
# => 10.0.22.104
```

しかし、IPアドレスが分かっても、インスタンスのネットワークが利用可能状態であるかを知る必要がある。SSHする前にpingによる疎通確認を行う。pingの終了ステータスコードで疎通可能であるかどうかを確認可能。0になるまで何度か確認する。疎通しない場合を考慮し、`-W 3`によりタイムアウトを設定している。

```
$ ping -c 1 -W 3 10.0.22.104 >/dev/null; echo $?
# => 1
$ ping -c 1 -W 3 10.0.22.104 >/dev/null; echo $?
# => 1
$ ping -c 1 -W 3 10.0.22.104 >/dev/null; echo $?
# => 1
$ ping -c 1 -W 3 10.0.22.104 >/dev/null; echo $?
# => 1
$ ping -c 1 -W 3 10.0.22.104 >/dev/null; echo $?
# => 1
$ ping -c 1 -W 3 10.0.22.104 >/dev/null; echo $?
# => 0
```

## tcp/22の状態を確認

疎通確認出来た直後にSSHしても、SSHデーモンが起動してるとは限らない。SSHデーモンが起動している事を確認する必要がある。ncコマンドの終了ステータスコードで疎通可能であるかどうかを確認可能。疎通しない場合を考慮し、`-w 3`によりタイムアウトを設定している。

```
$ nc -w 3 10.0.22.104 22 <<< '' >/dev/null; echo $?
# => 1
$ nc -w 3 10.0.22.104 22 <<< '' >/dev/null; echo $?
# => 1
$ nc -w 3 10.0.22.104 22 <<< '' >/dev/null; echo $?
# => 1
$ nc -w 3 10.0.22.104 22 <<< '' >/dev/null; echo $?
# => 0
```

## ssh

ようやくSSH。事前に生成したキーペアの秘密鍵を指定し、SSH接続する。なお、ユーザーはマシンイメージの仕様に依存する。wmi-centos1d64の場合は、rootである。

```
$ ssh -i mykeypair root@10.0.22.104 hostname
# => bbgjyac9
```

ホスト名が出力されれば成功だ。

## ここまでのまとめ

SSHにログインするまでに手順を確認する。

```
$ ssh-keygen -N "" -f mykeypair
$ mussel ssh_key_pair create ...
# => ssh-xxxxxxxxx

$ vi sgrule.txt
$ mussel security_group create ...
# => sg-xxxxxxxxx

$ cat vifs.json
$ mussel instance create \
# => i-xxxxxxxxx

$ mussel instance show i-xxxxxxxx | egrep ^:state:  # runningになるまで実施
# => :state: running
$ mussel instance show i-xxxxxxxx | egrep ":address:" | awk '{print $2}'
# => 10.0.22.104
$ ping -c 1 -W 3 10.0.22.104 >/dev/null; echo $?    # 0になるまで実施
# => 0
$ nc -w 3 10.0.22.104 22 <<< '' >/dev/null; echo $? # 0になるまで実施
# => 0

$ ssh -i mykeypair root@10.0.22.104 hostname
# => bbgjyac9
```

生成時に知っておけばよい情報は、uuidだけである。現在のAPIは、レスポンスメッセージに詳細情報を返して来るが、クライアントからすると、その大半が無駄な情報である。

## 1枚スクリプト化

まとめた手順を一枚のスクリプトにまとめてみる。

```
#!/bin/bash

set -e
set -o pipefail
set -x

#
ssh-keygen -N "" -f mykeypair
ssh_key_id="$(
  mussel ssh_key_pair create \
    --public-key mykeypair.pub \
  | egrep ^:id: \
  | awk '{print $2}'
)"

#
cat <<EOS > sgrule.txt
icmp:-1,-1,ip4:0.0.0.0/0
tcp:22,22,ip4:0.0.0.0/0
EOS
security_group_id="$(
  mussel security_group create \
    --rule sgrule.txt \
  | egrep ^:id: \
  | awk '{print $2}'
)"

#
cat <<EOS > vifs.json
{
 "eth0":{"network":"nw-demo1","security_groups":"${security_group_id}"}
}
instance_id="$(
  mussel instance create \
    --cpu-cores    1              \
    --hypervisor   kvm            \
    --image-id     wmi-centos1d64 \
    --memory-size  512            \
    --ssh-key-id   ${ssh_key_id}  \
    --vifs         vifs.json      \
  | egrep ^:id: \
  | awk '{print $2}'
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

#

retry_until [[ '"$(mussel instance show "${instance_id}" | egrep -w "^:state: running")"' ]]

ipaddr="$(
  mussel instance show "${instance_id}" \
  | egrep ":address:" \
  | awk '{print $2}'
)"

retry_until "ping -c 1 -W 3 ${ipaddr}    >/dev/null"
retry_until "nc -w 3 ${ipaddr} 22 <<< '' >/dev/null"

#
ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -i mykeypair root@${ipaddr}" hostname
```

## スクリプト改善点

1. musselにwait-forコマンドを用意し、ユーティリティとの組み合せを可能な限り排除する
2. mussel createの結果がuuidだけだと良い。そこで、createに`--output-format id`オプションを導入してみる。 ※オプション名は暫定

例えばmussel ssh_key_pair createの結果は、`ssh-xxxxxxxx`だ。

> ```
> $ mussel ssh_key_pair create --public-key  mykeypair.pub --output-format id
> ssh-xxxxxxxx
> ```

改善点を反映したスクリプトを書いてみると、こうなる。

```
#!/bin/bash

set -e
set -o pipefail
set -x

#
ssh-keygen -N "" -f mykeypair
ssh_key_id"$(
  mussel ssh_key_pair create \
   --public-key    mykeypair.pub \
   --output-format id
)"

#
cat <<EOS > sgrule.txt
icmp:-1,-1,ip4:0.0.0.0/0
tcp:22,22,ip4:0.0.0.0/0
EOS
security_group_id="$(
  mussel security_group create \
   --rule          sgrule.txt \
   --output-format id
)"

#
cat <<EOS > vifs.json
{
 "eth0":{"network":"nw-demo1","security_groups":"${security_group_id}"}
}
instance_id="$(
  mussel instance create \
   --cpu-cores     1              \
   --hypervisor    kvm            \
   --image-id      wmi-centos1d64 \
   --memory-size   512            \
   --ssh-key-id    ${ssh_key_id}  \
   --vifs          vifs.json      \
   --output-format id
)"

#
mussel instance wait-for-state   ${instance_id} --state running
mussel instance wait-for-network ${instance_id} --state opened --protocol icmp
mussel instance wait-for-network ${instance_id} --state opened --protocol tcp --port 22

#
ssh -o 'StrictHostKeyChecking no' -o 'UserKnownHostsFile /dev/null' -i mykeypair root@${ipaddr}" hostname
```

大分すっきりした。

## 今後へ向けた改善案(1)

### mussel

1. musselに`wait-for`コマンド群を用意し、ユーティリティとの組み合せを可能な限り排除する
2. 主に`mussel <resource> create`に`--output-format id`オプションを導入し、スクリプト作成をしやすくする ※オプション名募集
3. `mussel <resource> show`...の結果をフィルタしやすいように、ユーティリティを用意
   1. リソースの`:state:`。`wait-for`が無い場合は、良く使う。
   2. インスタンスやロードバランサーの`:address:`
   3. インスタンスのVIFs(ロードバランサーに追加する為に必要)

### API

#### POST: 【要改修】

+ `:id:`と`:uuid:`を返す(クライアントがidとuuid、どちらを参照しているかが不明)

```
$ mussel instance create \
 --hypervisor kvm \
 --cpu-cores 1 \
 --image-id wmi-centos1d64 \
 --memory-size 256 \
 --ssh-key-id ssh-ruekc3bs \
 --display-name vdc-instance \
 --vifs vifs.json
---
:id: i-3dyfffr2
:uuid: i-3dyfffr2
```

#### GET: 【現状維持】

+  詳細情報を返す

```
$ mussel instance show i-31zmj9fr
---
:id: i-31zmj9fr
:account_id: a-shpoolxx
:host_node: hn-1box64
:cpu_cores: 1
:memory_size: 256
:arch: x86_64
:image_id: wmi-centos1d64
:created_at: 2015-04-08 05:35:07.000000000 Z
:updated_at: 2015-04-08 05:35:28.000000000 Z
:terminated_at:
:deleted_at:
:state: running
:status: online
:ssh_key_pair:
  :uuid: ssh-ruekc3bs
  :display_name: mykeypair
:volume:
- :vol_id: vol-iednolgh
  :state: attached
:vif:
- :vif_id: vif-l9rjt9q2
  :network_id: nw-demo1
  :ipv4:
    :address: 10.0.2.100
    :nat_address:
  :security_groups:
  - sg-nhrd602s
:hostname: 31zmj9fr
:ha_enabled: 0
:hypervisor: kvm
:display_name: vdc-instance
:service_type: std
:monitoring:
  :enabled: false
  :mail_address: []
  :items: {}
:labels:
- :resource_uuid: i-31zmj9fr
  :name: monitoring.enabled
  :value_type: 1
  :value: 'false'
  :created_at: 2015-04-08 05:35:07.000000000 Z
  :updated_at: 2015-04-08 05:35:07.000000000 Z
:boot_volume_id: vol-iednolgh
:encrypted_password:
```

#### PUT: 【現状維持】

+ 自身の`:xxx_id:`と、変更対象となった`:xxxx_id:`を返す

```
$ mussel instance poweroff i-3dyfffr2
---
:instance_id: i-3dyfffr2
```

```
$ mussel instance backup i-0yuzzyd7 --display-name backup:i-0yuzzyd7
---
:instance_id: i-0yuzzyd7
:image_id: wmi-4yalh576
:backup_object_ids:
- bo-3bm4h97t
```

#### DELETE: 【現状維持】

+ (何故かhashではないのが気持ち悪い)

```
$ mussel instance destroy i-3dyfffr2
---
- i-3dyfffr2
```
