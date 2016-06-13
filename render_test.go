package render

import (
	"testing"
	"golang.org/x/net/context"
)

func TestTitle(t *testing.T) {
	ctx := context.Background()

	r, err := NewRenderer()
	if err != nil {
		t.Fatal(err)
	}

	v := r.NewView("go-render-unit", "none", true, true)

	if err := v.LoadURI("http://www.gooogle.com"); err != nil {
		t.Fatal(err)
	}

	if err := v.Wait(ctx); err != nil {
		t.Fatal(err)
	}

	if v.Title() != "Google" {
		t.Fatalf("Title %s != Google", v.Title())
	}
}
