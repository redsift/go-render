package render

import (
	"runtime"
	"sync"
	"github.com/auroralaboratories/go-webkit2/webkit2"
	"github.com/auroralaboratories/gotk3/glib"
	"github.com/auroralaboratories/gotk3/gtk"
	"github.com/sqs/gojs"
	"github.com/fsnotify/fsnotify"
	"errors"
	"time"
	"image"
	"os"
	"fmt"
	"log"
)

var (
	ErrLoadFailed = errors.New("load-failed")
	ErrViewClosed = errors.New("view-closed")
	ErrTimeout = errors.New("timeout")
	ErrNoImage = errors.New("no-image")
	ErrNoTiming = errors.New("load-not-timed")
	ErrNoX = errors.New("no-x-display")
)

var gtkOnce sync.Once


func newTimeout(t *time.Duration) chan bool {
	timeout := make(chan bool, 1)
	if t != nil && *t != 0 {
		go func() {
			time.Sleep(*t)
			timeout <- true
		}()
	}
	return timeout
}

type View struct {
	*webkit2.WebView
	load        chan struct{}
	lastLoadErr error
	closed bool

	loadRequested 	*time.Time
	loadStarted 	*time.Time
	loadFinished 	*time.Time
}

func (v *View) TimeToStart() (time.Duration, error) {
	if v.loadRequested == nil || v.loadStarted == nil {
		return 0, ErrNoTiming
	}

	return v.loadStarted.Sub(*v.loadRequested), nil
}

func (v *View) TimeToLoad() (time.Duration, error) {
	if v.loadStarted == nil || v.loadFinished == nil {
		return 0, ErrNoTiming
	}

	return v.loadFinished.Sub(*v.loadStarted), nil
}

func (v *View) TimeToFinish() (time.Duration, error) {
	if v.loadRequested == nil || v.loadFinished == nil {
		return 0, ErrNoTiming
	}

	return v.loadFinished.Sub(*v.loadRequested), nil
}

func (v *View) LoadURI(url string) error {
	if v.closed {
		return ErrViewClosed
	}

	v.load = make(chan struct{}, 1)
	v.lastLoadErr = nil
	v.loadRequested = nil
	v.loadStarted = nil
	v.loadFinished = nil

	glib.IdleAdd(func() bool {
		t := time.Now()
		v.loadRequested = &t
		v.WebView.LoadURI(url)
		return false
	})

	return nil
}

func (v *View) LoadHTML(content, baseURI string) error {
	if v.closed {
		return ErrViewClosed
	}

	v.load = make(chan struct{}, 1)
	v.lastLoadErr = nil
	v.loadRequested = nil
	v.loadStarted = nil
	v.loadFinished = nil

	glib.IdleAdd(func() bool {
		t := time.Now()
		v.loadRequested = &t
		v.WebView.LoadHTML(content, baseURI)
		return false
	})

	return nil
}

func (v *View)NewSnapshot(t *time.Duration) (result *image.RGBA, err error) {
	if v.closed {
		return nil, ErrViewClosed
	}

	resultChan := make(chan *image.RGBA, 1)
	errChan := make(chan error, 1)
	timeout := newTimeout(t)

	glib.IdleAdd(func() bool {
		v.GetSnapshot(func(img *image.RGBA, err error) {
			if err != nil {
				errChan <- err
				return
			}
			if img == nil {
				errChan <- ErrNoImage
				return
			}

			resultChan <- img
		})
		return false
	})

	select {
	case result = <-resultChan:
		return result, nil
	case err = <-errChan:
		return nil, err
	case <-timeout:
		return nil, ErrTimeout
	}
}

func (v *View) EvaluateJavaScript(script string, t *time.Duration) (result interface{}, err error) {
	if v.closed {
		return nil, ErrViewClosed
	}

	resultChan := make(chan interface{}, 1)
	errChan := make(chan error, 1)
	timeout := newTimeout(t)

	glib.IdleAdd(func() bool {
		v.WebView.RunJavaScript(script, func(result *gojs.Value, err error) {
			if err == nil {
				goval, err := result.GoValue()
				if err != nil {
					errChan <- err
					return
				}
				resultChan <- goval
			} else {
				errChan <- err
			}
			return
		})
		return false
	})

	select {
	case result = <-resultChan:
		return result, nil
	case err = <-errChan:
		return nil, err
	case <-timeout:
		return nil, ErrTimeout
	}
}

// waits for the current page to finish loading.
func (v *View) Wait(t *time.Duration) error {
	if v.closed {
		return ErrViewClosed
	}

	timeout := newTimeout(t)

	select {
	case <-timeout:
		return ErrTimeout
	case <-v.load:
		return v.lastLoadErr
	}

}

func (v *View) Close() {
	if v.closed {
		return
	}

	v.closed = true
	v.Destroy()
}

type renderer struct {
	sync.Mutex
}

const ENV_DISPLAY = "DISPLAY"
const X_LOCK_PARENT = "/tmp"

func (r *renderer) waitForX() error {
	d := os.Getenv(ENV_DISPLAY)
	if d == "" {
		return fmt.Errorf("No %s variable set for X", ENV_DISPLAY)
	}

	if len(d) < 2 {
		return fmt.Errorf("%s variable %q is malformed", ENV_DISPLAY, d)
	}
	n := d[1:]

	f := fmt.Sprintf("%s/.X%s-lock", X_LOCK_PARENT, n)

	w, err := fsnotify.NewWatcher()
	if err != nil {
		return err
	}
	defer w.Close()

	t := 10 * time.Second
	timeout := newTimeout(&t)
	found := make(chan struct{})

	go func() {
		for {
			select {
			case event := <-w.Events:
				if event.Op&fsnotify.Create == fsnotify.Create {
					if event.Name == f {
						// got it
						close(found)
					}
				}
			case err := <-w.Errors:
				if err != nil {
					panic(err)
				} // else the watcher was closed
			}
		}
	}()

	err = w.Add(X_LOCK_PARENT)
	if err != nil {
		return err
	}

	if _, err := os.Stat(f); os.IsNotExist(err) {
		log.Printf("Waiting on %s", f)
		select {
		case <-timeout:
			return ErrNoX
		case <-found:
			return nil
		}

	}

	return nil
}

func NewRenderer() (*renderer, error) {
	r := renderer{}

	if err := r.waitForX(); err != nil {
		return nil, err
	}

	r.start()

	return &r, nil
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


func (r *renderer) NewView(appName, appVersion string, autoLoadImages, consoleStdout bool) *View {
	c := make(chan *View, 1)

	r.Lock()

	glib.IdleAdd(func() bool {
		webView := webkit2.NewWebView()
		settings := webView.Settings()
		settings.SetAutoLoadImages(autoLoadImages)
		settings.SetEnableWriteConsoleMessagesToStdout(consoleStdout)
		settings.SetUserAgentWithApplicationDetails(appName, appVersion)
		v := &View{WebView: webView}
		loadChangedHandler, _ := webView.Connect("load-changed", func(_ *glib.Object, loadEvent webkit2.LoadEvent) {
			t := time.Now()
			switch loadEvent {
			case webkit2.LoadStarted:
				v.loadStarted = &t
			case webkit2.LoadFinished:
				v.loadFinished = &t
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
