package main

import (
	"fmt"
	"encoding/json"
	"os"
	"net/url"
	"gopkg.in/alecthomas/kingpin.v2"
	"github.com/redsift/go-render"
	"image/png"
	"text/template"
	"bytes"
	"strings"
)

// LIBGL_DEBUG=verbose to debug libGl issues

// These version tags are set from the git values during CI built
// and need to be var so ldflags can change them
var (
	Tag=""
	Commit=""
	Timestamp=""
)

var (
	app      		= kingpin.New("render", "Command-line WebKit based web page rendering tool.")
	debugOpt    		= app.Flag("debug", "Enable debug mode.").Short('d').Default("false").Bool()
	uaAppNameOpt   		= app.Flag("user-agent-app", "User agent application name.").Default("go-render").String()
	uaAppVersionOpt 	= app.Flag("user-agent-version", "User agent application version.").Default(Tag).String()
	consoleOpt    		= app.Flag("console", "Output webpage console to stdout.").Default("false").Bool()
	imagesOpt    		= app.Flag("images", "Load images from webpage.").Bool()
	timeoutOpt		= app.Flag("timeout", "Timeout for page load.").Short('t').Duration()

	snapshotCommand     	= app.Command("snapshot", "Generate a snapshot of the page.")
	snapshotFormat		= snapshotCommand.Flag("format", "File format for output").Short('f').Default("auto").Enum("auto", "png", "jpeg", "webp", "gif", "mono")
	snapshotQuality		= snapshotCommand.Flag("quality", "Quality of image when using lossy compression").Default("100").Int()
	snapshotOutput		= snapshotCommand.Flag("output", "Filename for output").Short('o').Required().String()
	snapshotOpt		= snapshotCommand.Arg("url", "URL").Required().URL()


	javascriptCommand     	= app.Command("javascript", "Execute javascript in the context of the page.")
	javascriptContent	= javascriptCommand.Flag("js", "Javascript to execute").Short('j').Required().String()
	javascriptOpt		= javascriptCommand.Arg("url", "URL").Required().URL()

	metadataCommand		= app.Command("metadata", "Get page metadata.")
	metadataFormat		= metadataCommand.Flag("format", "Format the output using the given go template").Short('f').Default("").String()
	metadataOpt		= metadataCommand.Arg("url", "URL").Required().URL()
)


type timing struct {
	Start float64
	Load float64
	Finish float64
}

type metadata struct {
	Title string
	URI string
	Timing timing
}

func Git() string {
	if Tag == "" {
		if Commit == "" {
			return "unknown"
		}
		return Commit
	}
	return fmt.Sprintf("%s-%s", Tag, Commit)
}

func Version() string {
	git := Git()
	if Timestamp == "" {
		return git
	}
	return fmt.Sprintf("%s-%s", git, Timestamp)
}

func newLoadedView(url *url.URL, autoLoadImages bool) *render.View {
	if url.Scheme == "" {
		url.Scheme = "http"
	}
 	u := url.String()

	r := render.NewRenderer()
	v := r.NewView(*uaAppNameOpt, *uaAppVersionOpt, autoLoadImages, *consoleOpt)

	if *debugOpt {
		fmt.Printf("Loading URL:%q\n", u)
	}

	err := v.LoadURI(u)
	app.FatalIfError(err, "Unable to request URL %q", u)

	err = v.Wait(timeoutOpt)
	app.FatalIfError(err, "Unable to load page")

	return v
}

func formatInterface(m interface{}, tmpl string) string {
	var b []byte
	var err error

	// Based on docker template functions
	var templateFuncs = template.FuncMap{
		"json": func(m interface{}) string {
			a, _ := json.MarshalIndent(m, "", "\t")
			return string(a)
		},
		"split": strings.Split,
		"join":  strings.Join,
		"title": strings.Title,
		"lower": strings.ToLower,
		"upper": strings.ToUpper,
	}

	if tmpl != "" {
		temp, err := template.New("").Funcs(templateFuncs).Parse(tmpl)
		app.FatalIfError(err, "Unable to parse template")

		buffer := new(bytes.Buffer)
		err = temp.Execute(buffer, m)
		app.FatalIfError(err, "Unable to format metadata")

		b = buffer.Bytes()
	} else {
		b, err = json.MarshalIndent(m, "", "\t")
		app.FatalIfError(err, "Unable to format metadata")
	}
	return string(b)
}

func main() {
	app.HelpFlag.Short('h')
	app.Version(Version())
	switch kingpin.MustParse(app.Parse(os.Args[1:])) {
	case snapshotCommand.FullCommand(): {
		al := true	// Give that this is a snapshot, load the images
		if imagesOpt != nil {
			al = *imagesOpt
		}
		v := newLoadedView(*snapshotOpt, al)
		defer v.Close()

		i, err := v.NewSnapshot(timeoutOpt)
		app.FatalIfError(err, "Unable to create snapshot")

		if i.Pix == nil {
			app.Fatalf("No Pix in captured image")
		}

		if i.Stride == 0 || i.Rect.Max.X == 0 || i.Rect.Max.Y == 0 {
			app.Fatalf("No image data in captured image")
		}

		imgFile := *snapshotOutput
		f, err := os.Create(imgFile)
		app.FatalIfError(err, "Could not create image %s", imgFile)
		defer f.Close()

		png.Encode(f, i)
	}
	case javascriptCommand.FullCommand(): {
		al := false
		if imagesOpt != nil {
			al = *imagesOpt
		}
		v := newLoadedView(*javascriptOpt, al)
		defer v.Close()

		j, err := v.EvaluateJavaScript(*javascriptContent, timeoutOpt)
		app.FatalIfError(err, "Unable to execute javascript")

		fmt.Println(j)
	}
	case metadataCommand.FullCommand(): {
		al := false
		if imagesOpt != nil {
			al = *imagesOpt
		}
		v := newLoadedView(*metadataOpt, al)
		defer v.Close()

		ts, _ := v.TimeToStart()
		tl, _ := v.TimeToLoad()
		tf, _ := v.TimeToFinish()

		m := metadata{
			Title: v.Title(),
			URI: v.URI(),
			Timing: timing{ Start: ts.Seconds(), Load: tl.Seconds(), Finish: tf.Seconds() },
		}

		fmt.Println(formatInterface(m, *metadataFormat))
	}
	default: {
		app.FatalUsage("No known command supplied")
	}
	}




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
		*/
}

