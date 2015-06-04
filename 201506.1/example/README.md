# Examples

## 1: ssh_key_pair

### gen-keypair.sh

```
$ gen-keypair.sh
```

+ input:
   + (none)
+ output:
   + `private_key` - string
   + `public_key` - string

> ```
> $ ./gen-keypair.sh
> [DEBUG:31418] Generating public/private rsa key pair.
> [DEBUG:31418] Your identification has been saved in keypair.31418.
> [DEBUG:31418] Your public key has been saved in keypair.31418.pub.
> [DEBUG:31418] The key fingerprint is:
> [DEBUG:31418] 32:91:06:dc:6d:23:65:20:1e:77:f4:32:a1:14:fe:23 knoppix@Microknoppix
> [DEBUG:31418] The key's randomart image is:
> [DEBUG:31418] +--[ RSA 2048]----+
> [DEBUG:31418] |   .+.=**        |
> [DEBUG:31418] |   ..Bo=+o       |
> [DEBUG:31418] |    . *oo..      |
> [DEBUG:31418] |     . o o       |
> [DEBUG:31418] |      E S        |
> [DEBUG:31418] |       + .       |
> [DEBUG:31418] |                 |
> [DEBUG:31418] |                 |
> [DEBUG:31418] |                 |
> [DEBUG:31418] +-----------------+
> [DEBUG:31418] -rw------- 1 knoppix knoppix 1679 Jun  4 14:46 keypair.31418
> [DEBUG:31418] -rw-r--r-- 1 knoppix knoppix  402 Jun  4 14:46 keypair.31418.pub
> private_key=keypair.31418
> public_key=keypair.31418.pub
> ```

### ssh_key_pair-create.sh

```
$ public_key=${private_key} ./ssh_key_pair-create.sh
```

+ input:
   + `public_key` - file
+ output:
   + `ssh_key_id` - string

> ```
> $ public_key=keypair.31418.pub ./ssh_key_pair-create.sh
> [DEBUG:31434] ---
> [DEBUG:31434] :id: ssh-s7vamwp5
> [DEBUG:31434] :account_id: a-shpoolxx
> [DEBUG:31434] :uuid: ssh-s7vamwp5
> [DEBUG:31434] :finger_print: 2d:88:38:b0:6b:30:6d:65:a3:d7:89:c3:f1:d7:12:5c
> [DEBUG:31434] :public_key: |
> [DEBUG:31434]   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCyXrjZXaD7EBf4ryVbP02YfS8h/tm/lBWYmmPA11iZ4SuJOWo3laBSL9PJ+nptkxxoVjPbCFAgYbsFuQvGjg2yQ3uBZhLyldo+mHwJh9lm+GGWxz0dQtk7EiFyu/dTRsFDAT1UZ9hvvZjcsHnVz1Mm7t3TYY2mGLhacwVTyUg6JPRrSI0r4M34amI8VvNfS5OrBTdU6YFBM9gsCFj6oKL25VC4e6zp8MCf6E1a6pmrzYr/p8Y7CpGQ5GlHm3hK0AN9QA9KQbiKuGByXBo1Lu9GyBgTF4tCZh3d305GiNOXwn7FPjashwIDBafWviIySsu3Rg1IRCYhAbku9u7jZsdv knoppix@Microknoppix
> [DEBUG:31434] :description: ''
> [DEBUG:31434] :created_at: 2015-06-04 05:47:16.000000000 Z
> [DEBUG:31434] :updated_at: 2015-06-04 05:47:16.000000000 Z
> [DEBUG:31434] :service_type: std
> [DEBUG:31434] :display_name: keypair.31418.pub
> [DEBUG:31434] :deleted_at:
> [DEBUG:31434] :labels: []
> ssh_key_id=ssh-s7vamwp5
> ```

## 2: security_groups

### rulefile

```
$ vi sgrule.txt
```

```
icmp:-1,-1,ip4:0.0.0.0/0
tcp:22,22,ip4:0.0.0.0/0
tcp:80,80,ip4:0.0.0.0/0
tcp:8080,8080,ip4:0.0.0.0/0
```

### security_group-create.sh

```
$ rule=sgrule.txt ./security_group-create.sh
```

+ input
   + `rule` - file
+ output:
   + `security_group_id` - string

> ```
> $ rule=sgrule.txt ./security_group-create.sh
> [DEBUG:31622] ---
> [DEBUG:31622] :id: sg-paz1t0aa
> [DEBUG:31622] :account_id: a-shpoolxx
> [DEBUG:31622] :uuid: sg-paz1t0aa
> [DEBUG:31622] :created_at: 2015-06-04 05:51:40.000000000 Z
> [DEBUG:31622] :updated_at: 2015-06-04 05:51:40.000000000 Z
> [DEBUG:31622] :description:
> [DEBUG:31622] :rule: |
> [DEBUG:31622]   icmp:-1,-1,ip4:0.0.0.0/0
> [DEBUG:31622]   tcp:22,22,ip4:0.0.0.0/0
> [DEBUG:31622]   tcp:80,80,ip4:0.0.0.0/0
> [DEBUG:31622]   tcp:8080,8080,ip4:0.0.0.0/0
> [DEBUG:31622] :service_type: std
> [DEBUG:31622] :display_name: ''
> [DEBUG:31622] :labels: []
> [DEBUG:31622] :rules:
> [DEBUG:31622] - :ip_protocol: icmp
> [DEBUG:31622]   :icmp_type: -1
> [DEBUG:31622]   :icmp_code: -1
> [DEBUG:31622]   :protocol: ip4
> [DEBUG:31622]   :ip_source: 0.0.0.0/0
> [DEBUG:31622] - :ip_protocol: tcp
> [DEBUG:31622]   :ip_fport: 22
> [DEBUG:31622]   :ip_tport: 22
> [DEBUG:31622]   :protocol: ip4
> [DEBUG:31622]   :ip_source: 0.0.0.0/0
> [DEBUG:31622] - :ip_protocol: tcp
> [DEBUG:31622]   :ip_fport: 80
> [DEBUG:31622]   :ip_tport: 80
> [DEBUG:31622]   :protocol: ip4
> [DEBUG:31622]   :ip_source: 0.0.0.0/0
> [DEBUG:31622] - :ip_protocol: tcp
> [DEBUG:31622]   :ip_fport: 8080
> [DEBUG:31622]   :ip_tport: 8080
> [DEBUG:31622]   :protocol: ip4
> [DEBUG:31622]   :ip_source: 0.0.0.0/0
> security_group_id=sg-paz1t0aa
```

## 3: vifs

```
$ vifs=vifs.json network_id=nw-demo1 security_group_id=<sg-***> ./gen-vifs.sh
```

+ input:
  + `vifs` - file
  + `network_id` - string
  + `security_group_id` - string
+ output:
  + `vifs` - string

> ```
> $ vifs=vifs.json network_id=nw-demo1 security_group_id=sg-paz1t0aa ./gen-vifs.sh
> [DEBUG:32015] {
> [DEBUG:32015]  "eth0":{"network":"nw-demo1","security_groups":"sg-paz1t0aa"}
> [DEBUG:32015] }
> vifs=vifs.json
> ```

## 4: instance

```
$ cpu_cores=1 hypervisor=kvm memory_size=256 image_id=wmi-centos1d64 ssh_key_id=ssh-s7vamwp5 vifs=./vifs.json ./instance-create.sh
```

+ input:
  + `cpu_cores` - integer
  + `hypervisor` - string
  + `memory_size` - integer
  + `image_id` - string
  + `ssh_key_id` - string
  + `vifs` - file
+ output:
  + `instance_id` - string

> ```
> $ cpu_cores=1 hypervisor=kvm memory_size=256 image_id=wmi-centos1d64 ssh_key_id=ssh-s7vamwp5 vifs=./vifs.json ./instance-create.sh
> [DEBUG:1296] ---
> [DEBUG:1296] :id: i-72q36e3k
> [DEBUG:1296] :account_id: a-shpoolxx
> [DEBUG:1296] :host_node:
> [DEBUG:1296] :cpu_cores: 1
> [DEBUG:1296] :memory_size: 256
> [DEBUG:1296] :arch: x86_64
> [DEBUG:1296] :image_id: wmi-centos1d64
> [DEBUG:1296] :created_at: 2015-06-04 06:22:35.000000000 Z
> [DEBUG:1296] :updated_at: 2015-06-04 06:22:35.688098619 Z
> [DEBUG:1296] :terminated_at:
> [DEBUG:1296] :deleted_at:
> [DEBUG:1296] :state: scheduling
> [DEBUG:1296] :status: init
> [DEBUG:1296] :ssh_key_pair:
> [DEBUG:1296]   :uuid: ssh-s7vamwp5
> [DEBUG:1296]   :display_name: ''
> [DEBUG:1296] :volume:
> [DEBUG:1296] - :vol_id: vol-lp1sv5fd
> [DEBUG:1296]   :state: scheduling
> [DEBUG:1296] :vif: []
> [DEBUG:1296] :hostname: 72q36e3k
> [DEBUG:1296] :ha_enabled: 0
> [DEBUG:1296] :hypervisor: kvm
> [DEBUG:1296] :display_name: '20150604152236'
> [DEBUG:1296] :service_type: std
> [DEBUG:1296] :monitoring:
> [DEBUG:1296]   :enabled: false
> [DEBUG:1296]   :mail_address: []
> [DEBUG:1296]   :items: {}
> [DEBUG:1296] :labels:
> [DEBUG:1296] - :resource_uuid: i-72q36e3k
> [DEBUG:1296]   :name: monitoring.enabled
> [DEBUG:1296]   :value_type: 1
> [DEBUG:1296]   :value: 'false'
> [DEBUG:1296]   :created_at: 2015-06-04 06:22:35.000000000 Z
> [DEBUG:1296]   :updated_at: 2015-06-04 06:22:35.000000000 Z
> [DEBUG:1296] :boot_volume_id: vol-lp1sv5fd
> [DEBUG:1296] :encrypted_password:
> instance_id=i-72q36e3k
> ```

```
$ instance_id=<i-***> ./instance-wait4ssh.sh
```

+ input:
  + `instance_id` - string
+ output:
  + `ipaddr` - string

> ```
> $ instance_id=i-72q36e3k ./instance-wait4ssh.sh
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> [DEBUG:11127]
> [DEBUG:11127] [2015-06-04T04:20:11 PM #11127] time:1 eval:
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> [DEBUG:11127]
> [DEBUG:11127] [2015-06-04T04:20:17 PM #11127] time:2 eval:
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> [DEBUG:11127]
> [DEBUG:11127] [2015-06-04T04:20:23 PM #11127] time:3 eval:
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> [DEBUG:11127]
> [DEBUG:11127] [2015-06-04T04:20:29 PM #11127] time:4 eval:
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> [DEBUG:11127]
> [DEBUG:11127] [2015-06-04T04:20:35 PM #11127] time:5 eval:
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> [DEBUG:11127]
> [DEBUG:11127] [2015-06-04T04:20:41 PM #11127] time:6 eval:
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> [DEBUG:11127]
> [DEBUG:11127] [2015-06-04T04:20:47 PM #11127] time:7 eval:
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 0 received, 100% packet loss, time 0ms
> [DEBUG:11127]
> [DEBUG:11127] [2015-06-04T04:20:53 PM #11127] time:8 eval:
> [DEBUG:11127] PING 10.0.22.104 (10.0.22.104) 56(84) bytes of data.
> [DEBUG:11127] 64 bytes from 10.0.22.104: icmp_req=1 ttl=64 time=1.88 ms
> [DEBUG:11127]
> [DEBUG:11127] --- 10.0.22.104 ping statistics ---
> [DEBUG:11127] 1 packets transmitted, 1 received, 0% packet loss, time 0ms
> [DEBUG:11127] rtt min/avg/max/mdev = 1.880/1.880/1.880/0.000 ms
> [DEBUG:11127] SSH-2.0-OpenSSH_5.3
> [DEBUG:11127] Protocol mismatch.
> ipaddr=10.0.22.104
> ```

```
$ instance_id=<i-***> ssh_user=root private_key=<private-key> ./instance-exec.sh
```

+ input:
  + `instance_id` - string
  + `ssh_user` - string
  + `private_key` - file
+ output:
  + (none)

>```
> $ instance_id=i-72q36e3k ssh_user=root private_key=keypair.31418 ./instance-exec.sh hostname
> [DEBUG:6249] ---
> [DEBUG:6249] :id: i-72q36e3k
> [DEBUG:6249] :account_id: a-shpoolxx
> [DEBUG:6249] :host_node: hn-demo1
> [DEBUG:6249] :cpu_cores: 1
> [DEBUG:6249] :memory_size: 256
> [DEBUG:6249] :arch: x86_64
> [DEBUG:6249] :image_id: wmi-centos1d64
> [DEBUG:6249] :created_at: 2015-06-04 06:22:35.000000000 Z
> [DEBUG:6249] :updated_at: 2015-06-04 06:23:17.000000000 Z
> [DEBUG:6249] :terminated_at:
> [DEBUG:6249] :deleted_at:
> [DEBUG:6249] :state: running
> [DEBUG:6249] :status: online
> [DEBUG:6249] :ssh_key_pair:
> [DEBUG:6249]   :uuid: ssh-s7vamwp5
> [DEBUG:6249]   :display_name: ''
> [DEBUG:6249] :volume:
> [DEBUG:6249] - :vol_id: vol-lp1sv5fd
> [DEBUG:6249]   :state: attached
> [DEBUG:6249] :vif:
> [DEBUG:6249] - :vif_id: vif-pcm24k3v
> [DEBUG:6249]   :network_id: nw-demo1
> [DEBUG:6249]   :ipv4:
> [DEBUG:6249]     :address: 10.0.22.104
> [DEBUG:6249]     :nat_address:
> [DEBUG:6249]   :security_groups:
> [DEBUG:6249]   - sg-paz1t0aa
> [DEBUG:6249] :hostname: 72q36e3k
> [DEBUG:6249] :ha_enabled: 0
> [DEBUG:6249] :hypervisor: kvm
> [DEBUG:6249] :display_name: '20150604152236'
> [DEBUG:6249] :service_type: std
> [DEBUG:6249] :monitoring:
> [DEBUG:6249]   :enabled: false
> [DEBUG:6249]   :mail_address: []
> [DEBUG:6249]   :items: {}
> [DEBUG:6249] :labels:
> [DEBUG:6249] - :resource_uuid: i-72q36e3k
> [DEBUG:6249]   :name: monitoring.enabled
> [DEBUG:6249]   :value_type: 1
> [DEBUG:6249]   :value: 'false'
> [DEBUG:6249]   :created_at: 2015-06-04 06:22:35.000000000 Z
> [DEBUG:6249]   :updated_at: 2015-06-04 06:22:35.000000000 Z
> [DEBUG:6249] :boot_volume_id: vol-lp1sv5fd
> [DEBUG:6249] :encrypted_password:
> Warning: Permanently added '10.0.22.104' (RSA) to the list of known hosts.
> 72q36e3k
> ```

## Cleanup

### instance-destroy.sh

```
$ instance_id=<i-***> ./instance-destroy.sh
```

+ input:
  + `instance_id` - string
+ output:
  + `instance_id` - string

> ```
> $ instance_id=i-72q36e3k ./instance-destroy.sh
> [DEBUG:7035] ---
> [DEBUG:7035] - i-72q36e3k
> instance_id=i-72q36e3k
> ```

### security_group-destroy.sh

```
$ security_group_id=sg-paz1t0aa ./security_group-destroy.sh
```

> ```
> $ security_group_id=sg-paz1t0aa ./security_group-destroy.sh
> [DEBUG:7501] ---
> [DEBUG:7501] - sg-paz1t0aa
> security_group_id=sg-paz1t0aa
> ```

### ssh_key_pair-destroy.sh

```
$ ssh_key_id=ssh-s7vamwp5 ./ssh_key_pair-destroy.sh
```

> ```
> $ ssh_key_id=ssh-s7vamwp5 ./ssh_key_pair-destroy.sh
> [DEBUG:8318] ---
> [DEBUG:8318] - ssh-s7vamwp5
> ssh_key_id=ssh-s7vamwp5
> ```
