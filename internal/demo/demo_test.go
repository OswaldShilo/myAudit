package demo

import (
	"os"
	"path/filepath"
	"testing"
)

func TestDirFromEmbed(t *testing.T) {
	t.Setenv("MYAUDIT_DEMO", "")
	// Force embed path: cwd without ./demo
	dir, err := os.MkdirTemp("", "myaudit-demo-test")
	if err != nil {
		t.Fatal(err)
	}
	t.Chdir(dir)

	p, err := Dir()
	if err != nil {
		t.Fatal(err)
	}
	if _, err := os.Stat(filepath.Join(p, "index.js")); err != nil {
		t.Fatalf("expected embedded demo at %s: %v", p, err)
	}
}
