package main

import (
	"fmt"
	"io"
	"net/http"
	"os/exec"
)

// start server
func main() {
	fs := http.FileServer(http.Dir("."))
	http.HandleFunc("/token", handleToken)

	go exec.Command("open http://localhost:3000/")
    http.ListenAndServe(":3000", fs)
}

// recieve token from webview, print it, then kill server
func handleToken(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Must be a post request.", http.StatusMethodNotAllowed)
		return
	}

	body, err := io.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Error reading request body", http.StatusBadRequest)
		return
	}

	fmt.Println(string(body))
	panic(string(body))
}
