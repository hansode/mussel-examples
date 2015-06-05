#!/bin/bash

set -e
set -o pipefail
set -u

##

keyfile="keypair.${$}"
private_key="${keyfile}"
public_key="${keyfile}.pub"

##

{
  ssh-keygen -N "" -f "${keyfile}"
  ls -l "${private_key}" "${public_key}"
} | sed "s,^,[D:${$}] ," >&2

##

echo private_key="${private_key}"
echo public_key="${public_key}"
