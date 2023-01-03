package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/user"
	"strings"
)

var key string = ""

func main() {
	flag.Usage = usage
	flag.Parse()

	arg := flag.Args()[0]
	method := ""
	switch arg {
	case "currently-playing":
		method = http.MethodGet
	case "play":
		method = http.MethodPut
	case "pause":
		method = http.MethodPut
	case "next":
		method = http.MethodPost
	case "previous":
		method = http.MethodPost
	}

	res, err := sptReq(arg, method)
	if err != nil {
		os.Exit(1)
	}
	fmt.Println(res)
}

func usage() {
	fmt.Fprintf(os.Stderr, "usage: myprog [inputfile]\n")
	flag.PrintDefaults()
	os.Exit(2)
}

func getKey() string {
	if key != "" {
		return key
	}

	user, err := user.Current()
	if err != nil {
		fmt.Println("Couldn't get home directory.")
		os.Exit(3)
	}

	keydoc, err := os.ReadFile(user.HomeDir + "/.config/spotifyd/statusify.key")
	if err != nil {
		fmt.Println("Couldn't find key document.")
		os.Exit(3)
	}

	key = "Bearer " + string(keydoc)
	if strings.Contains(key, "\n") {
		key = key[0 : len(key)-1]
	}

	return key
}

type Response struct {
	Error ErrorResponse `json:"error"`
}

type ErrorResponse struct {
	Status  int    `json:"status"`
	Message string `json:"message"`
}

func sptReq(e string, m string) (string, error) {
	spt := "https://api.spotify.com/v1/me/player/"
	client := &http.Client{}

	req, err := http.NewRequest(m, spt+e, nil)
	if err != nil {
		fmt.Println("Error in making request " + e + "\n" + err.Error() + "\n")
		return "", err
	}

	k := getKey()
	req.Header.Add("Authorization", k)
	log.Println(req.Header)

	res, err := client.Do(req)
	if err != nil {
		fmt.Println("Error in doing request " + e + "\n" + err.Error() + "\n")
		return "", err
	}

	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)
	if err != nil {
		fmt.Println("Error in reading body" + e + "\n" + err.Error() + "\n")
		return "", err
	}

	if res.StatusCode != http.StatusOK {
		var rj Response
		err := json.Unmarshal(body, &rj)
		if err != nil {
			return "", fmt.Errorf("couldn't parse json response\n%v", string(body))
		}

		if rj.Error.Message == "The access token expired" {
			return rj.Error.Message, nil
		}

		return "", fmt.Errorf("error in response\n%v", rj.Error.Message)
	}

	return string(body), nil
}
