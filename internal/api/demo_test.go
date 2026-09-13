package api

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestDemoEndpoint(t *testing.T) {
	s := newStore(t)
	srv := httptest.NewServer(NewMux(s, nil))
	defer srv.Close()

	resp, err := http.Get(srv.URL + "/api/demo")
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close()
	if resp.StatusCode != 200 {
		t.Fatalf("status %d", resp.StatusCode)
	}
	var body map[string]string
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		t.Fatal(err)
	}
	p := body["path"]
	if p == "" {
		t.Fatal("missing path")
	}
	if _, err := os.Stat(filepath.Join(p, "index.js")); err != nil {
		t.Fatalf("demo index.js missing at %s: %v", p, err)
	}
}
