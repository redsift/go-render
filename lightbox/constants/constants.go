package constants

//go:generate $GOPATH/bin/stringer -type=Format

// Format represents a detected image format
type Format int

// Known image formats
const (
	Unknown Format = iota
	Auto
	PNG
	JPEG
	WEBP
	GIF
	MONO
	SVG
)

// MIME types for known image formats
const (
	MIMEPNG  = "image/png"
	MIMEJPEG = "image/jpeg"
	MIMEWEBP = "image/webp"
	MIMEGIF  = "image/gif"
	MIMESVG  = "image/svg+xml"
)

var mimeList = []string{MIMEPNG, MIMEWEBP, MIMEJPEG, MIMESVG, MIMEGIF}

// MIMEList is the MIMT ype list of all known image formats in order of preference
func MIMEList() []string {
	return mimeList
}

func (f Format)MIMEString() string {
	switch f {
	case PNG:
		return MIMEPNG
	case JPEG:
		return MIMEJPEG
	case WEBP:
		return MIMEWEBP
	case GIF:
		return MIMEGIF
	case SVG:
		return MIMESVG
	default:
		return "application/octet-stream"
	}
}