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
