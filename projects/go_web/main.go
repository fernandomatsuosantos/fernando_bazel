package main

import (
	"fmt"
	"net/http"
	"log"
	"time"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request){
        fmt.Fprintf(w, "Hello! The time is ", time.Now())
    })

    fmt.Printf("Starting server at port 8080\n")
    if err := http.ListenAndServe("localhost:8080", nil); err != nil {
        log.Fatal(err)
    }
}