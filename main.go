package main

import (
	"github.com/fatih/color"
	"github.com/wistonk/go-k8s-app-demo/router"
	"log"
	"net/http"
	"os"
)


func main() {
    //export SERVE_PORT=:8888
	//Get the value of the SERVE_PORT environment variable
	addr := os.Getenv("SERVE_PORT")

	r := router.Router()

	color.Red("server is listening at: localhost" + addr)
	log.Fatal(http.ListenAndServe(addr, r))
}
