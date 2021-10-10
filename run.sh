#!/bin/bash

set -e
set -o pipefail

HOST_NAME=local.ecosia.org
REGISTRY_USERNAME=wistonk
IMAGE_NAME=go-k8s-app-demo

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

check_host_if_exists () {
  echo "---------------------------host: $1 ----------------------------------- "
  if result=$(grep -n $1 /etc/hosts -wc) > /dev/null 2>&1; then
    echo "$1 exists"
  else
    echo "$1 not found. Adding $1..."
    $2
  fi
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

}

function start_minikube () {
  echo "--------------------------- starting minikube ------------------------------ "
  minikube delete --all --purge
  minikube start --vm=true --driver=hyperkit

}

function add_host () {

  ip_address=$(minikube ip)
  host_entry="${ip_address} ${HOST_NAME}"

  echo "Adding host ${host_entry}"
  echo "$host_entry" | sudo tee -a /etc/hosts > /dev/null

}

manage_minikube_addons () {
  echo "--------------------------- enabling minikube addons ------------------------------ "
  minikube addons enable ingress
}

docker_build_and_scan(){
  echo "--------------------------- building an image -------------------------------- "
  docker build -t $IMAGE_NAME .

  echo "--------------------------- vulnerability scanning (for demo purpose, vuln not fixed) -------------------------------------"
  # uncomment for vulnerability scanning
  # docker scan --file Dockerfile $IMAGE_NAME
}

docker_tag_and_push(){
  echo "--------------------------- tag the image -------------------------------------"
  docker tag $IMAGE_NAME $REGISTRY_USERNAME/$IMAGE_NAME:latest

  echo "--------------------------- push the image -------------------------------------"
  docker push $REGISTRY_USERNAME/$IMAGE_NAME:latest
}

apply_k8s_manifests () {
  echo "--------------------------- running k8s manifests ------------------------------ "
  kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
  kubectl apply -k k8s/base/
}

app_testing () {
  echo "--------------------------- checking the app service ---------------------------- "
  minikube service go-k8s-app-demo --url

  echo "############################ testing the hostname ############################### "
  sleep 10;
  curl http://local.ecosia.org/tree

  echo "################ congratulations!! you successfully deployment the app ########## "

}

main(){
  check_installed_package "kubectl" install_kubectl
  check_installed_package "minikube" install_minikube
  check_minikube_status "status" "running" "minikube not found, will start now ..." start_minikube
  check_package_version "kubectl" "version --short"
  check_package_version "minikube" "version --short"
  docker_build_and_scan
  docker_tag_and_push
  manage_minikube_addons
  apply_k8s_manifests
  check_host_if_exists "$HOST_NAME" add_host
  app_testing
}

main "$@"