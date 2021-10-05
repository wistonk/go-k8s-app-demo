package models

type Result struct {
    MyFavouriteTree string `json:"myFavouriteTree,omitempty"`
}

var Results = Result{
	MyFavouriteTree: "Moringa",
}
