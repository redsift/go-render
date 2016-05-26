package render

import (
	"testing"
	"github.com/redsift/go-render/version"
)

func TestTitle(t *testing.T) {
	r := NewRenderer()
	v := r.NewView("go-render-unit", version.Tag, true, true)

	if err := v.LoadURI("http://www.gooogle.com"); err != nil {
		t.Fatal(err)
	}

	if err := v.Wait(nil); err != nil {
		t.Fatal(err)
	}

	if v.Title() != "Google" {
		t.Fatalf("Title %s != Google", v.Title())
	}
}
