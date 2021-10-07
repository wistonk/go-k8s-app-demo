#!/usr/bin/env bash

set -e
set -o pipefail

check_installed_package () {
  echo "--------------------------- $1 ----------------------------------- "
  if command -v $1 > /dev/null 2>&1; then
    echo "$1 already installed"
  else
    echo "$1 not found. Installing $1..."
    $2
  fi
}

check_minikube_status () {
  echo "--------------------------- $1 ----------------------------------- "
  if minikube $1 > /dev/null 2>&1; then
    echo "$1: $2"
  else
    echo "$1: $3"
    $4
  fi
}

check_package_version () {
  echo "--------------------------- $1 version ------------------------------ "
  $1 $2
}

function install_kubectl () {
  if [[ -n "$(command -v brew)" ]]; then
    brew install kubectl
  elif [[ -n "$(command -v apt)" ]]; then
    sudo apt-get install kubectl
  elif [[ -n "$(command -v yum)" ]]; then
    sudo yum install kubectl
  else
    echo "Unsupported OS"
  fi
}

function install_minikube () {
  if [[ -n "$(command -v brew)" ]]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64
    sudo install minikube-darwin-amd64 /usr/local/bin/minikube
  elif [[ -n "$(command -v apt)" ]]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
  elif [[ -n "$(command -v yum)" ]]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube

  else
    echo "Unsupported OS"
  fi
  chown -R $USER $HOME/.minikube; chmod -R u+wrx $HOME/.minikube
}

function start_minikube () {
  echo "--------------------------- starting minikube ------------------------------ "
  minikube delete --all --purge
  minikube start
}

manage_minikube_addons () {
  echo "--------------------------- enabling minikube addons ------------------------------ "
  minikube addons enable ingress
  minikube tunnel
}

docker_build_tag_push(){
  echo "--------------------------- build docker image -------------------------------- "
  docker build https://github.com/wistonk/go-k8s-app-demo.git

  echo "--------------------------- tag docker image -------------------------------------"

  echo "--------------------------- push docker image -------------------------------------"
}

apply_k8s_manifests () {
  echo "--------------------------- running k8s manifests ------------------------------ "
  kubectl get no
  # Apply resources from a directory containing kustomization.yaml - e.g. dir/kustomization.yaml
  # kubectl apply -k dir/
  # sudo minikube service list
  #  curl http://<LOCAL_IP>:<PORT>
}

main(){
  check_installed_package "kubectl" install_kubectl
  check_installed_package "minikube" install_minikube
  check_minikube_status "status" "running" "minikube not found, will start now ..." start_minikube
  check_package_version "kubectl" "version --short"
  check_package_version "minikube" "version --short"
  docker_build_tag_push
  #manage_minikube_addons
  #apply_k8s_manifests
}

main "$@"