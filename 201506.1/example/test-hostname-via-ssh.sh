#!/bin/bash

set -e
set -o pipefail
set -u
set -x

# cleanup

trap '
{
 if [[ -n "${instance_id}" ]]; then
   instance_id="${instance_id}" \
   ./instance-destroy.sh
 fi
 if [[ -n "${security_group_id}" ]]; then
   security_group_id="${security_group_id}" \
   ./security_group-destroy.sh
 fi
 if [[ -n "${ssh_key_id}" ]]; then
   ssh_key_id="${ssh_key_id}" \
   ./ssh_key_pair-destroy.sh
 fi
 rm -f "${private_key}"
 rm -f "${public_key}"
} | sed "s,^,[D:${$}] ," >&2
' ERR EXIT

# params

rule=./sgrule.txt
vifs=./vifs.json

network_id=nw-demo1
cpu_cores=1
hypervisor=kvm
memory_size=256
image_id=wmi-centos1d64

## ssh

ssh_user=root

# main

## keypair

eval "$(
  ./gen-keypair.sh
)"
: "${public_key:?"should not be empty"}"
: "${private_key:?"should not be empty"}"

eval "$(
  public_key="${public_key}" \
  ./ssh_key_pair-create.sh
)"
: "${ssh_key_id:?"should not be empty"}"

## sg

eval "$(
  rule="${rule}" \
  ./security_group-create.sh
)"
: "${security_group_id:?"should not be empty"}"

## vif

eval "$(
  vifs="${vifs}" \
  network_id="${network_id}" \
  security_group_id="${security_group_id}" \
  ./gen-vifs.sh
)"
: "${vifs:?"should not be empty"}"

## instance

eval "$(
  cpu_cores=1 \
  hypervisor=kvm \
  memory_size=256 \
  image_id=wmi-centos1d64 \
  ssh_key_id="${ssh_key_id}" \
  vifs=./vifs.json \
  ./instance-create.sh
)"
: "${instance_id:?"should not be empty"}"

## wait-for ssh

instance_id="${instance_id}" \
 ./instance-wait4ssh.sh

## hostname

instance_id="${instance_id}" \
ssh_user="${ssh_user}" \
private_key="${private_key}" \
 ./instance-exec.sh hostname
