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
)

// MIME types for known image formats
const (
	MIMEPNG  = "image/png"
	MIMEJPEG = "image/jpeg"
	MIMEWEBP = "image/webp"
	MIMEGIF  = "image/gif"
)

var mimeList = []string{MIMEPNG, MIMEWEBP, MIMEJPEG, MIMEGIF}

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
	default:
		return "application/octet-stream"
	}
}