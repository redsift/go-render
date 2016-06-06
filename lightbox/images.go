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

// FormatParse converts the string representation of format into the enum
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
		return Unknown, fmt.Errorf("Unknown format %q", n)
	}
}

// FormatParseFromFilename returns a format based on the supplied file extension
func FormatParseFromFilename(n string) (Format, error) {
	mt := mime.TypeByExtension(filepath.Ext(n))

	switch mt {
	case MIMEPNG:
		return PNG, nil
	case MIMEJPEG:
		return JPEG, nil
	case MIMEWEBP:
		return WEBP, nil
	case MIMEGIF:
		return GIF, nil
	default:
		return Unknown, fmt.Errorf("Unknown extension format %q", n)
	}
}

// FormatParseFromAccept returns a format based on the supplied Accept header
func FormatParseFromAccept(a string) (Format, error) {
	ct := httphelp.Negotiate(a, MIMEList())

	if ct == "" {
		return Unknown, errors.New("No content type could be negotiated")
	}
	return PNG, nil
}

// Encode writes img in the desired image format f to the out stream. If the selected format
// is a lossy format, quality between 1-100 represents the strength of compression with 1 being
// the highest compressions / lowest quality and 100 being the lowest compression / highest quality.
// If the format supports lossless compression (e.g. WebP) in addition to lossy compression, quality
// values > 100 represent lossless compression.
func Encode(f Format, out io.Writer, img image.Image, quality int) error {
	switch f {
	case Auto, Unknown, PNG:
		return png.Encode(out, img)
	case JPEG:
		o := jpeg.Options{Quality: quality}
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
}
