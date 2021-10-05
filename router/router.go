package router

//import (
//	"wistonk-devops-test/middleware"
//
//	"github.com/gorilla/mux"
//)
//
//// Router is exported and used in main.go
//func Router() *mux.Router {
//
//	router := mux.NewRouter().StrictSlash(true)
//
//	router.HandleFunc("/", middleware.Home)
//	router.HandleFunc("/configs", middleware.GetConfigs).Methods("GET")
//	router.HandleFunc("/configs", middleware.PostConfigs).Methods("POST")
//	router.HandleFunc("/configs/{name}", middleware.GetConfigsByName).Methods("GET")
//	router.HandleFunc("/configs/{name}", middleware.UpdateConfigsByName).Methods("PATCH")
//	router.HandleFunc("/configs/{name}", middleware.DeleteConfigsByName).Methods("DELETE")
//	router.HandleFunc("/search", middleware.SearchMetadataByKeyValue).Methods("GET").Queries("metadata.monitoring.enabled", "{status}")
//
//	return router
//}
