package middleware

import (
	"encoding/json"
	"github.com/fatih/color"
	"github.com/wistonk/go-k8s-app-demo/models"
	"net/http"
)



func GetMyFavouriteTree(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("content-type", "application/json")
	w.WriteHeader(http.StatusOK)
	color.Blue("Invoke GetConfigs API")

	json.NewEncoder(w).Encode(models.Results)
}
