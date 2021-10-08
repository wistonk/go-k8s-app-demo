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
