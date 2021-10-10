# Go web server

## Goals

- [x] Coding a web server
- [x] Automating its deployment into a Kubernetes cluster

![GO](https://golang.org/lib/godoc/images/go-logo-blue.svg)

## Solution
This repository contains containerized Go web server, ready for minukube deployment.

### Prerequisites
- Install [GO](https://golang.org/doc/install)

#### Fetching Dependencies
Clone this repository to your machine
`$ git clone https://github.com/wistonk/go-k8s-app-demo.git`

Initialize the Go modules with your GitHub repository address or your project
`$ go mod init go-k8s-app-demo`

You can fetch the Go modules using the following commands.i.e
```
$ go get -u github.com/gorilla/mux 
$ go get -u github.com/fatih/color
```
#### Scaffolding the GO web server
Create the app using the below file structure
```
|--main.go
|--router/router.go
|--middleware/handlers.go
|--models/models.go
|--k8s/base/deploy.yaml
           /deployment.yaml
           /ingress.yaml
           /kustomization.yaml
           /service.yaml
```
The `main.go` file contains the entry point for our application. It should contain the following code:
```
package main

import (
	"github.com/fatih/color"
	"github.com/wistonk/go-k8s-app-demo/router"
	"log"
	"net/http"
)


func main() {
	r := router.Router()

	color.Red("server is listening at: localhost:8888")
	log.Fatal(http.ListenAndServe(":8888", r))
}

```

> We then have `router/router.go` which we use to route our request to a `GetMyFavouriteTree` function. Check below the content of this file.

```
package router

import (
	"github.com/gorilla/mux"
	"github.com/wistonk/go-k8s-app-demo/middleware"
)

// Router is exported and used in main.go
func Router() *mux.Router {

	router := mux.NewRouter().StrictSlash(true)
	router.HandleFunc("/tree", middleware.GetMyFavouriteTree).Methods("GET")

	return router
}

```
Finally, we have the `middleware/handlers.go`. Here we implement the functions and the logic required. See below the code structure.

```
package middleware

import (
	"encoding/json"
	"github.com/fatih/color"
	"github.com/wistonk/go-k8s-app-demo/models"
	"net/http"
)


func GetMyFavouriteTree(w http.ResponseWriter, r *http.Request) {
	color.Blue("Invoke GetMyFavouriteTree API")

	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusOK)

	json.NewEncoder(w).Encode(models.Results)
}

```
#### Go Tests
In this part, we will write some tests.i.e. `Check HTTP Status Response Code`, `Check Request HTTP Method` or even `Check Empty Response`. See below code structure.

```
package main

import (
	"github.com/wistonk/go-k8s-app-demo/middleware"
	"net/http"
	"net/http/httptest"
	"testing"
)

// Helper Function
func performRequest(r http.Handler, method, path string) *httptest.ResponseRecorder {
	req, _ := http.NewRequest(method, path, nil)
	w := httptest.NewRecorder()
	r.ServeHTTP(w, req)
	return w
}

func TestGetMyFavouriteTreeRouter(t *testing.T) {
	req, err := http.NewRequest("GET", "/tree", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()

	handler := http.HandlerFunc(middleware.GetMyFavouriteTree)
	handler.ServeHTTP(rr, req)

	rr.Header().Set("content-type", "application/json")

	// Check HTTP Status Code
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	// Check Request HTTP Method
	if status := req.Method; status != http.MethodGet {
		t.Errorf("handler returned method: got %v want %v",
			status, req.Method)
	}

	// Check Empty Response
	if rr.Body.String() == "{}" {
		t.Errorf("handler returned unexpected body: got an empty json %v want %v",
			"{}", rr.Body.String())
	}
}
```

#### Containerize the Go web server
In order to deploy the app to our minikube cluster, we create a `Dockerfile` for building the image. Below is an example.

```
FROM golang:1.16-alpine as builder

COPY . /src/
WORKDIR /src

EXPOSE 8888

RUN go build

FROM alpine

COPY --from=builder /src/go-k8s-app-demo /

ENTRYPOINT ["/go-k8s-app-demo"]
```

We then use [bash script](https://github.com/wistonk/go-k8s-app-demo/blob/main/run.sh) to build, scan, tag and push the docker image to our preffered redistry. We will see detailed view the bash script later on.

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
|[app_testing](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L118) | - | check the service and since it takes some time to create an ingress, wait a bit before visiting `http://local.ecosia.org/tree` in your browser | you should see `{"myFavouriteTree":"Moringa"}` |
|[main](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L130) | - | entrypoint to the script | - |

### Testing the host

Open your terminal and run `curl http://local.ecosia.org/tree`. You should be able to view the output as `{"myFavouriteTree":"Moringa"}`

# Go web server demo
docker run -d -p 80:8888 go-k8s-app-demo:latest
