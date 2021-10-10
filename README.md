# Go web server

# Goals

- [x] Create a simple HTTP service that stores and returns configurations that satisfy certain conditions.
- [x] Create manifests that are automatically deployed to Kubernetes.

![GO](https://golang.org/lib/godoc/images/go-logo-blue.svg)

# Solution
## Prerequisites
- Install [GO](https://golang.org/doc/install)

## Fetching Dependencies
Clone this repository to your machine
`$ git clone https://github.com/hellofreshdevtests/wistonk-devops-test.git`

Initialize the Go modules with your GitHub repository address or your project
`$ go mod init wistonk-devops-test`

You can fetch the Go modules using the following commands.i.e
```
$ go get -u github.com/gorilla/mux 
$ go get -u github.com/fatih/color
```
## Scaffolding the GO HTTP service
Create the app using the below file structure
```
|--main.go
|--router/router.go
|--middleware/handlers.go
|--models/models.go
|--k8s/deploy.yaml
```
The `main.go` file contains the entry point for our application. It should contain the following code:
```
import (
	"github.com/fatih/color"
	"log"
	"net/http"
	"os"
	"wistonk-devops-test/router"
)

func main() {

	//Get the value of the SERVE_PORT environment variable
	addr := os.Getenv("SERVE_PORT")

	r := router.Router()

	color.Red("server is listening at: localhost" + addr)
	log.Fatal(http.ListenAndServe(addr, r))
}

```

> Before you run this, make sure you export the `SERVE_PORT` env variable i.e. `export SERVE_PORT=:4000`. 
We then have `router/router.go` which we use to route our request to a particular function. Check below the content of this file.

```
package router

import (
	"wistonk-devops-test/middleware"

	"github.com/gorilla/mux"
)

// Router is exported and used in main.go
func Router() *mux.Router {

	router := mux.NewRouter().StrictSlash(true)

	router.HandleFunc("/", middleware.Home)
	router.HandleFunc("/configs", middleware.GetConfigs).Methods("GET")
	router.HandleFunc("/configs", middleware.PostConfigs).Methods("POST")
	router.HandleFunc("/configs/{name}", middleware.GetConfigsByName).Methods("GET")
	router.HandleFunc("/configs/{name}", middleware.UpdateConfigsByName).Methods("PATCH")
	router.HandleFunc("/configs/{name}", middleware.DeleteConfigsByName).Methods("DELETE")
	router.HandleFunc("/search", middleware.SearchMetadataByKeyValue).Methods("GET").Queries("metadata.monitoring.enabled", "{status}")

	return router
}

```
Finally, we have the `middleware/handlers.go`. Here we implement the functions and the logic required. See below the code structure.

```
package middleware

import (
	"encoding/json"
	"fmt"
	"github.com/fatih/color"
	"github.com/gorilla/mux"
	"io/ioutil"
	"log"
	"net/http"
	"wistonk-devops-test/models"
)

func Home(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "text/plain")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, ":: Home page ::")
}

func GetConfigs(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusOK)
	color.Blue("Invoke GetConfigs API")

	json.NewEncoder(w).Encode(models.Configs)
}

func PostConfigs(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusCreated)
	color.Magenta("Invoke PostConfigs API")

	var newConfig models.Config

	// Convert r.Body into a readable format
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Fprintf(w, "Kindly enter data with the name and metadata object only in order to update")
		w.WriteHeader(http.StatusBadRequest)
	}
	params := mux.Vars(r)
	log.Printf("params %s...", params)

	json.Unmarshal(reqBody, &newConfig)

	// Add the newly created config to the array of configs
	models.Configs = append(models.Configs, newConfig)

	// Return the 201 created status code
	w.WriteHeader(http.StatusCreated)
	// Return the newly created config
	json.NewEncoder(w).Encode(newConfig)
}

func GetConfigsByName(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusOK)
	color.Green("Invoke GetConfigsByName API")

	// Get the Name from the url
	name := mux.Vars(r)["name"]

	// Get the details from an existing config
	// Use the blank identifier to avoid creating a value that will not be used
	for _, singleConfig := range models.Configs {
		if singleConfig.Name == name {
			json.NewEncoder(w).Encode(singleConfig)
		}
	}
}

func UpdateConfigsByName(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusCreated)
	color.Yellow("Invoke UpdateConfigsByName API")

	// Get the Name from the url
	name := mux.Vars(r)["name"]

	var updatedConfig models.Config
	// Convert r.Body into a readable formart
	reqBody, err := ioutil.ReadAll(r.Body)
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "Kindly enter data with the config name and metadata struct  in order to update")
	}

	json.Unmarshal(reqBody, &updatedConfig)

	for i, singleConfig := range models.Configs {
		if singleConfig.Name == name {
			singleConfig.Metadata = updatedConfig.Metadata
			models.Configs[i] = singleConfig
			json.NewEncoder(w).Encode(singleConfig)
		}
	}
}

func DeleteConfigsByName(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "text/plain")
	color.White("Invoke DeleteConfigsByName API")

	// Get the Name from the url
	name := mux.Vars(r)["name"]

	// Get the details from an existing config
	// Use the blank identifier to avoid creating a value that will not be used
	for i, singleConfig := range models.Configs {
		if singleConfig.Name == name {
			models.Configs = append(models.Configs[:i], models.Configs[i+1:]...)
			fmt.Fprintf(w, "The config with name '%v' has been deleted successfully", name)
		}
	}
}

func SearchMetadataByKeyValue(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusOK)
	color.Green("Invoke SearchMetadataByKeyValue API")

	var configurations []models.Config

	// Get the Name from the url
	status := mux.Vars(r)["status"]

	//Get the details from an existing config
	for _, singleConfig := range models.Configs {
		if singleConfig.Metadata.Monitoring.Enabled == status {
			configurations = append(configurations, singleConfig)
		}
	}
	json.NewEncoder(w).Encode(configurations)
}

```
## Go Tests
In this part, we will write tests based on the requirements. I have a simple test to check the expected output of `/` path. This calls the `Home` function on the `middleware/handlers.go`. See below code structure.

```
package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"wistonk-devops-test/middleware"
)

func TestHomeHandler(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatal(err)
	}

	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(middleware.Home)

	handler.ServeHTTP(rr, req)

	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v",
			status, http.StatusOK)
	}

	expected := `:: Home page ::`
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v",
			rr.Body.String(), expected)
	}
}

```

## Setting up manifests for Kubernetes

### Containerize the HTTP Service
In order to deploy the app to our Kubernetes cluster, we create a `Dockerfile` for building the image. Below is an example.

```
ROM golang:alpine

WORKDIR /app
COPY . /app

RUN go build -o main .

CMD ["/app/main"]
```
- _Build the image with this command_
`docker build -t wistonk-devops-test .`

- _Check the image that we created_
 `docker images`

- _Tag the image with any registry format.i.e GCR, ACR, ECR, or Dockerhub_
  `docker tag registry-username/wistonk-devops-test:tagname`

- _Push the image to the registry_
`docker push registry-username/wistonk-devops-test:tagname`

### Setup Cluster
#### Prerequisites
- install [Kubectl](https://kubernetes.io/docs/tasks/tools/)

You can setup your cluster on variuos options:
- via [EKS](https://docs.aws.amazon.com/eks/latest/userguide/create-cluster.html)
- via [GKE](https://cloud.google.com/kubernetes-engine/docs/quickstart#create_cluster)
- via [Minikube](https://minikube.sigs.k8s.io/docs/start/)

Once the cluster is successfully created, apply the Kubernetes manifests with below command.
`kubectl apply -f k8s/deploy.yaml`

## Testing the app with a rest client.
#### Prerequisites
- install [Postman](https://www.postman.com/downloads/)

You can use any rest clients of your choice to test the app. Here I use postman. Navigate to the `postman` directory to see sample payloads collection named `Hellofresh.postman_collection.json`. Import it into your postman client and test them. You should get the expected result.







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
|[app_testing](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L118) | - | check the service and since it takes some time to create an ingress, wait a bit before visiting `http://local.ecosia.org/tree` in your browser | you should see `{"myFavouriteTree":"Moringa"}` |
|[main](https://github.com/wistonk/go-k8s-app-demo/blob/b60e85f33b42cf6c7021eb9f1283292eb032d5a0/run.sh#L130) | - | entrypoint to the script | - |

### Testing the host

Open your terminal and run `curl http://local.ecosia.org/tree`. You should be able to view the output as `{"myFavouriteTree":"Moringa"}`

# Go web server demo
docker run -d -p 80:8888 go-k8s-app-demo:latest
