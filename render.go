package main

import (
	"github.com/gotk3/gotk3/gtk"
	"runtime"
	"sync"
	"github.com/sourcegraph/go-webkit2/webkit2"
	"github.com/gotk3/gotk3/glib"
	"errors"
	"github.com/sqs/gojs"
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
	r := renderer{nil}
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
	view := make(chan *view, 1)

	r.Lock()

	glib.IdleAdd(func() bool {
		webView := webkit2.NewWebView()
		settings := webView.Settings()
		settings.SetEnableWriteConsoleMessagesToStdout(true)
		settings.SetUserAgentWithApplicationDetails("Blocks", "v1")
		v := &view{WebView: webView}
		loadChangedHandler, _ := webView.Connect("load-changed", func(_ *glib.Object, loadEvent webkit2.LoadEvent) {
			switch loadEvent {
			case webkit2.LoadFinished:
				v.load <- struct{}{}
			}
		})
		webView.Connect("load-failed", func() {
			v.lastLoadErr = ErrLoadFailed
			webView.HandlerDisconnect(loadChangedHandler)
		})
		view <- v
		return false
	})

	r.Unlock()

	return <-view
}

func main() {


}
