package main

import (
	"fmt"
	"net/http"
	"strings"
	"testing"
)

func TestCurrentlyPlaying(t *testing.T) {
	res, err := sptReq("currently-playing", http.MethodGet)
	if err != nil {
		t.Error(err.Error())
	}
	t.Log(res)
	fmt.Println(res)
}

func TestPause(t *testing.T) {
	res, err := sptReq("pause", http.MethodPut)
	if err != nil {
		t.Error(err.Error())
	}
	t.Log(res)
	fmt.Println(res)
}

func TestGetKey(t *testing.T) {
	k := getKey()
	if strings.Contains(k, "\n") {
		t.Error("has a return")
	}
	t.Log(k)
}
