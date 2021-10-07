#!/usr/bin/env bash

set -ex
set -o pipefail

# check packages
function check_package () {
  echo $1
  if command -v $1 > /dev/null 2>&1; then
    echo "$1 already installed"
  else
    echo "$1 not found. Installing $1..."
    $2
  fi

}

# build the packer ami
build_ami(){
  echo "--------------------------- Build Reaction AMI -------------------------------- "
  packer build packer/template.json 
  echo "--------------------------- AMI Build Done -------------------------------------"
}

main(){
  build_ami
}

main "$@"

if minikube $1 > /dev/null 2>&1; then
    echo "$1: running"
  else
    echo "$1 not found. Running $1..."
    $2
  fi