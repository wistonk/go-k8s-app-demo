package main

import (
	"log"
	"net/http"
	"os"
	"github.com/fatih/color"
	"github.com/wistonk/go-k8s-app-demo/router"
)


func main() {

	//Get the value of the SERVE_PORT environment variable
	addr := os.Getenv("SERVE_PORT")

	r := router.Router()

	color.Red("server is listening at: localhost" + addr)
	log.Fatal(http.ListenAndServe(addr, r))
}
