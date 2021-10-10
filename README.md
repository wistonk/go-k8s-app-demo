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
|[check_installed_package](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L10) | `kubectl/minikube` | check packages if exists. i.e. `kubectl & minikube` | if not, call the respective function to install them |
|[install_kubectl](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L44) | - | install **kubectl** - _a command-line tool, that allows you to run commands against Kubernetes clusters_ | - |
|[install_minikube](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L56) | - | install **minikube**, _a local Kubernetes tooling, focusing on making it easy to learn and develop for Kubernetes_| - |
|[check_minikube_status](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L20) | `status`, `running`, `minikube not found, will start now ...` | check if **minikube** is running  | if not running, start it |
|[start_minikube](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L73) | - | purge any existing _profile_, start **minikube** using `hyperkit` driver | you can use any driver you want, [see list of drivers](https://minikube.sigs.k8s.io/docs/drivers/) |
|[check_package_version](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L29) | `kubectl/minikube version --short` | check the installed version | - |
|[docker_build_and_scan](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L95) | - | building the app image | uncomment `docker scan --file Dockerfile $IMAGE_NAME` for vulnerability scanning if you want to do so` |
|[docker_tag_and_push](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L104) | - | tag the image | - |
|[manage_minikube_addons](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L90) | - | pushing the image | am using `dockerhub`, feel free to use any other registry i.e. `acr, ecr, gcr` etc provided you update the k8s manifests |
|[apply_k8s_manifests](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L112) | - | run k8s manifests at `/k8s` directory | I optionally delete `ValidatingWebhookConfiguration` when I need to re-run the script a couple of times |
|[check_host_if_exists](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L34) | `$HOST_NAME` | Check whether the host `local.ecosia.org` is configured in `/etc/hosts` | if not, we call `add_host` function to add it. |
|[add_host](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L80) | - | add an entry to `/etc/hosts` for `minikube  ip` and `local.ecosia.org` | - |
|[app_testing](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L118) | - | check the service and since it takes some time to create an ingress, wait a bit before curling `curl http://local.ecosia.org/tree` | you should be able to view the output `{"myFavouriteTree":"Moringa"}` |
|[main](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L130) | - | entrypoint to the script | - |

### Testing the hostname

Please see [CONTRIBUTING.md](CONTRIBUTING.md) for instructions on how to contribute.

# Go web server demo
docker run -d -p 80:8888 go-k8s-app-demo:latest
