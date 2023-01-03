package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/user"
	"strings"
)

var key string = ""

const (
	Current = "currently-playing"
	Play    = "play"
	Pause   = "pause"
	Next    = "next"
	Prev    = "previous"
)

func main() {
	flag.Usage = usage
	flag.Parse()

	arg := flag.Args()[0]
	method := ""
	switch arg {
	case Current:
		method = http.MethodGet
	case Play:
		method = http.MethodPut
	case Pause:
		method = http.MethodPut
	case Next:
		method = http.MethodPost
	case Prev:
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
	Progress  uint32 `json:"progress_ms"`
	PlayState bool   `json:"is_playing"`
	Item      struct {
		Duration int      `json:"duration_ms"`
		Name     string   `json:"name"`
		Artists  []Artist `json:"artists"`
		Album    struct {
			AlbumArt []AlbumArt `json:"images"`
		} `json:"album"`
	} `json:"item"`
	Error ErrorResponse `json:"error"`
}

type Artist struct {
	Name string `json:"name"`
}

type AlbumArt struct {
	Height int    `json:"height"`
	Width  int    `json:"width"`
	Url    string `json:"url"`
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

	var rj Response
	if res.StatusCode != http.StatusOK {
		err := json.Unmarshal(body, &rj)
		if err != nil {
			return "", fmt.Errorf("couldn't parse json response\n%v", string(body))
		}

		if rj.Error.Message == "The access token expired" {
			return rj.Error.Message, nil
		}

		return "", fmt.Errorf("error in response\n%v", rj.Error.Message)
	}

	if e == Current {
		err := json.Unmarshal(body, &rj)
		if err != nil {
			return "", fmt.Errorf("couldn't parse json response\n%v", string(body))
		}

		artists := ""
		for _, x := range rj.Item.Artists {
			artists += ", " + x.Name
		}
		artists = artists[2:]

		albumart := rj.Item.Album.AlbumArt[1].Url

		return fmt.Sprintf(`{
            "name": "%v",
            "progress": %d,
            "play_state": %t,
            "duration": %d,
            "artists": "%v",
            "album_art": "%v"
        }`, rj.Item.Name, rj.Progress, rj.PlayState, rj.Item.Duration, artists, albumart), nil
	}

	return string(body), nil
}
