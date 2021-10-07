#!/usr/bin/env bash

set -ex
set -o pipefail

# Provision an AMI based on a Kubernetes AMI
function check_package () {
  echo $1
  if command -v $1 > /dev/null 2>&1; then
    echo "$1 already installed"
  else
    echo "$1 not found. Installing $1..."
    $2
  fi

}

function install_packer () {
  if [[ -n "$(command -v brew)" ]]; then
    brew install packer
  elif [[ -n "$(command -v apt)" ]]; then
    sudo apt-get install packer
  elif [[ -n "$(command -v yum)" ]]; then
    sudo yum install packer
  else
    echo "Unsupported OS"
  fi
}

function inspect_and_validate () {
  echo "--------------------------- Inspect Reaction AMI ------------------------------ "
  packer inspect packer/template.json
  echo "--------------------------- Validate Reaction AMI ----------------------------- "
  packer validate packer/template.json
  echo "Validation successful"
}


check_package "packer" install_packer
inspect_and_validate
