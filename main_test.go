package main

import (
	"github.com/wistonk/go-k8s-app-demo/middleware"
	"net/http"
	"net/http/httptest"
	"testing"
)



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