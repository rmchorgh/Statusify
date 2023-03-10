package main

import (
	_ "embed"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"os/user"
)

// start server
func main() {
	http.HandleFunc("/", handler)
	http.HandleFunc("/token", handlerRecieve)

	http.ListenAndServe(":3000", nil)
	go func() {
		exec.Command("/usr/bin/open", "http://localhost:3000")
	}()
}

//go:embed index.html
var index string

func handler(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case http.MethodGet:
		io.WriteString(w, index)
	case http.MethodPost:
		body, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "Couldn't read the request body.'", http.StatusBadRequest)
			return
		}

		io.WriteString(w, "Recieved.")

		user, err := user.Current()
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
			return
		}

		f, err := os.Create(user.HomeDir + "/.config/spotifyd/statusify.key")
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
			return
		}
		defer f.Close()

		f.WriteString(string(body))
		fmt.Println(string(body))

		os.Exit(0)
		panic("STOP")
	}
}

//go:embed recieve.html
var recieve string

func handlerRecieve(w http.ResponseWriter, r *http.Request) {
	io.WriteString(w, recieve)
}
