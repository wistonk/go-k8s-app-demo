# Kubernetes based Go web server

This repository contains containerized Go web server, ready for minukube deployment.

## Getting Started

### Development

#### Boostrapping the app
#### Testings (Go tests)

### Deployment
#### Containerization//Dockerfile
#### Bash Script
In this demo, we use this [bash script](https://github.com/wistonk/go-k8s-app-demo/blob/main/run.sh) which creates a [minikube](https://minikube.sigs.k8s.io/docs/start/) cluster and deploys the demo app. 

To grant the permission, run 
```
chmod +x ./run.sh
```
 To run the script 
 ```
 ./run.sh
 ```

Our script automates minikube, installation, starting the cluster, deploying and testing the app. Below are daited functions used by the script

|Function  | Arguments | Description | Additional Info|
------------- | ------------- | ------------ | ------------ |
|[check_installed_package](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L10) | kubectl/minikube | yyy | zzzz |
|[install_kubectl](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L44) | - | yyy | zzzz |
|[install_minikube](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L56) | - | yyy | zzzz |
|[check_minikube_status](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L20) | status/running/minikube not found, will start now ... | yyy | zzzz |
|[start_minikube](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L73) | - | yyy | zzzz |
|[check_package_version](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L29) | kubectl/minikube version --short | yyy | zzzz |
|[docker_build_and_scan](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L95) | - | yyy | zzzz |
|[docker_tag_and_push](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L104) | - | yyy | zzzz |
|[manage_minikube_addons](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L90) | - | yyy | zzzz |
|[apply_k8s_manifests](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L112) | - | yyy | zzzz |
|[check_host_if_exists](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L34) | hostname | yyy | zzzz |
|[add_host](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L80) | - | yyy | zzzz |
|[app_testing](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L118) | - | yyy | zzzz |
|[main](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L130) | - | sss | rrr |

### Testing the hostname

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to contribute.

# Go web server demo
docker run -d -p 80:8888 go-k8s-app-demo:latest
