package main

import (
	"runtime"
	"sync"
	"github.com/auroralaboratories/go-webkit2/webkit2"
	"github.com/auroralaboratories/gotk3/glib"
	"github.com/auroralaboratories/gotk3/gtk"
	"github.com/sqs/gojs"
	"errors"
	"fmt"
	"image"
	"os"
	"strconv"
	"image/png"
)

var ErrLoadFailed = errors.New("load-failed")
var ErrViewClosed = errors.New("view-closed")

var gtkOnce sync.Once

type view struct {
	*webkit2.WebView
	load        chan struct{}
	lastLoadErr error
	closed bool
}

func (v *view) LoadURI(url string) error {
	if v.closed {
		return ErrViewClosed
	}

	v.load = make(chan struct{}, 1)
	v.lastLoadErr = nil
	glib.IdleAdd(func() bool {

		v.WebView.LoadURI(url)
		return false
	})

	return nil
}

func (v *view) LoadHTML(content, baseURI string) error {
	if v.closed {
		return ErrViewClosed
	}

	v.load = make(chan struct{}, 1)
	v.lastLoadErr = nil
	glib.IdleAdd(func() bool {

		v.WebView.LoadHTML(content, baseURI)
		return false
	})

	return nil
}

func (v *view) EvaluateJavaScript(script string) (result interface{}, err error) {
	if v.closed {
		return nil, ErrViewClosed
	}

	resultChan := make(chan interface{}, 1)
	errChan := make(chan error, 1)

	glib.IdleAdd(func() bool {
		v.WebView.RunJavaScript(script, func(result *gojs.Value, err error) {
			glib.IdleAdd(func() bool {
				if err == nil {
					goval, err := result.GoValue()
					if err != nil {
						errChan <- err
						return false
					}
					resultChan <- goval
				} else {
					errChan <- err
				}
				return false
			})
		})
		return false
	})

	select {
	case result = <-resultChan:
		return result, nil
	case err = <-errChan:
		return nil, err
	}
}

// Wait waits for the current page to finish loading.
func (v *view) Wait() error {
	if v.closed {
		return ErrViewClosed
	}

	<-v.load
	return v.lastLoadErr
}

func (v *view) Close() {
	if v.closed {
		return
	}

	v.closed = true
	v.Destroy()
}

type renderer struct {
	sync.Mutex
}

func NewRenderer() *renderer {
	r := renderer{}
	r.start()
	return &r
}

// Ensure that the GTK+ main loop has started. If it has already been
func (r *renderer) start() {
	gtkOnce.Do(func() {
		gtk.Init(nil)
		go func() {
			runtime.LockOSThread()
			gtk.Main()
		}()
	})
}

func (r *renderer) NewView() *view {
	c := make(chan *view, 1)
	defer close(c)

	r.Lock()

	glib.IdleAdd(func() bool {
		webView := webkit2.NewWebView()
		settings := webView.Settings()
		settings.SetEnableWriteConsoleMessagesToStdout(true)
		settings.SetUserAgentWithApplicationDetails("go-render", "v1")
		v := &view{WebView: webView}
		loadChangedHandler, _ := webView.Connect("load-changed", func(_ *glib.Object, loadEvent webkit2.LoadEvent) {
			switch loadEvent {
			case webkit2.LoadFinished:
				webView.GetSnapshot(func(img *image.RGBA, err error) {
					if err != nil {
						fmt.Printf("INLINE GetSnapshot error: %q", err)
						return
					}

					println("SNAP OK!")
				})

				v.load <- struct{}{}
			}
		})
		webView.Connect("load-failed", func() {
			v.lastLoadErr = ErrLoadFailed
			webView.HandlerDisconnect(loadChangedHandler)
		})
		c <- v
		return false
	})

	r.Unlock()

	return <-c
}

func main() {
	println("--------GO---------")

	r := NewRenderer()
	v := r.NewView()
	if err := v.LoadURI("http://www.shazam.com"); err != nil {
		panic(err)
	}
	defer v.Close()

	if err := v.Wait(); err != nil {
		panic(err)
	}

	println(v.Title())
	println(v.URI())

/*
	c := make(chan *gojs.Value, 1)
	defer close(c)
	glib.IdleAdd(func() bool {
		v.RunJavaScript("window.location.hostname", func(val *gojs.Value, err error) {
			if err != nil {
				panic(err)
			} else {
				fmt.Printf("Hostname (from JavaScript): %q\n", val)
				c <- val
			}
		})

		return false
	})
*/

	c := make(chan error, 1)
	glib.IdleAdd(func() bool {
		v.GetSnapshot(func(img *image.RGBA, err error) {
			defer close(c)
			if err != nil {
				fmt.Printf("GetSnapshot error: %q", err)
				fmt.Printf("GetSnapshot img: %v", img)
				c <- err
				return
			}
			if img == nil {
				fmt.Printf("!img")
				return
			}

			if img.Pix == nil {
				fmt.Printf("!img.Pix")
				return
			}

			if img.Stride == 0 || img.Rect.Max.X == 0 || img.Rect.Max.Y == 0 {
				fmt.Printf("!img.Stride or !img.Rect.Max.X or !img.Rect.Max.Y")
				return
			}

			f, err := os.Create("x" + strconv.Itoa(1) + ".png")
			png.Encode(f, img)

			fmt.Println("Grab finished.")
		})
		return false
	})

	result := <- c
	if result != nil {
		println(result.Error())
	}
}

// LIBGL_DEBUG=verbose
// http://unix.stackexchange.com/questions/1437/what-does-libgl-always-indirect-1-actually-do
// LIBGL_ALWAYS_INDIRECT=1