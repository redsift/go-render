package lightbox

import (
	"errors"
	"fmt"
	"github.com/chai2010/webp"
	. "github.com/redsift/go-render/lightbox/constants"
	"github.com/ricallinson/httphelp"
	"image"
	"image/gif"
	"image/jpeg"
	"image/png"
	"io"
	"mime"
	"path/filepath"
	"strings"
)

func FormatParse(n string) (Format, error) {
	switch strings.ToLower(n) {
	case "auto":
		return Auto, nil
	case "png":
		return PNG, nil
	case "jpeg":
		return JPEG, nil
	case "webp":
		return WEBP, nil
	case "gif":
		return GIF, nil
	case "mono":
		return MONO, nil
	default:
		return nil, fmt.Errorf("Unknown format %q", n)
	}
}

func FormatParseFromFilename(n string) (Format, error) {
	mt := mime.TypeByExtension(filepath.Ext(n))

	switch mt {
	case MIMEPNG:
		return PNG
	case MIMEJPEG:
		return JPEG
	case MIMEWEBP:
		return WEBP
	case MIMEGIF:
		return GIF
	default:
		return nil, fmt.Errorf("Unknown extension format %q", n)
	}
}

func FormatParseFromAccept(a string) Format {
	ct := httphelp.Negotiate(a, MIMEList())

	if ct == nil {
		return nil, errors.New("No content type could be negotiated")
	}
	return PNG
}

func Encode(f Format, out io.Writer, img image.Image, quality int) error {
	switch f {
	case Auto, nil, PNG:
		return png.Encode(out, img)
	case JPEG:
		o := jpeg.Options{quality}
		return jpeg.Encode(out, img, &o)
	case GIF:
		return gif.Encode(out, img, nil)
	case WEBP:
		o := webp.Options{}
		if quality > 100 {
			o.Lossless = true
		} else {
			o.Lossless = false
			o.Quality = float32(quality)
		}
		return webp.Encode(out, img, &o)
	default:
		panic(fmt.Sprintf("Format %s not implemented", f))
	}

	return nil
}
