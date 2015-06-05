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
$ mussel instance show i-xxxxxxxx | | egrep ":address:" | awk '{print $2}'
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
$ mussel instance show i-xxxxxxxx | | egrep ":address:" | awk '{print $2}'
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
```

## スクリプト改善点

1. musselにwait-forコマンドを用意し、ユーティリティとの組み合せを可能な限り排除する
2. mussel createの結果がuuidだけだと良い。そこで、createに`--output-format simple`オプションを導入してみる。

例えばmussel ssh_key_pair createの結果は、`ssh_key_id=ssh-xxxxxxxx`だ。

> ```
> $ mussel ssh_key_pair create --public-key  mykeypair.pub --output-format shell
> ssh_key_id=ssh-xxxxxxxx
> ```

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
   --output-format simple
)"

#
cat <<EOS > sgrule.txt
icmp:-1,-1,ip4:0.0.0.0/0
tcp:22,22,ip4:0.0.0.0/0
EOS
security_group_id="$(
  mussel security_group create \
   --rule          sgrule.txt \
   --output-format simple
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
   --output-format simple
)"

#
mussel instance wait-for-state   ${instance_id} --state running
mussel instance wait-for-network ${instance_id} --state open
mussel instance wait-for-ssh     ${instance_id} --private-key ${private_key} --user root hostname
```

大分すっきりした。

## 今後へ向けた改善案

mussel

1. musselにwait-forコマンドを用意し、ユーティリティとの組み合せを可能な限り排除する
2. mussel createに`--output-format simple`オプションを導入し、スクリプト作成をしやすくする

API

1. GETは、詳細情報を返し
2. POST, PUT, DELETEは、最小限情報であるuuidだけを返す
