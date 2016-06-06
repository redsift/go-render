package constants

//go:generate $GOPATH/bin/stringer -type=Format

type Format int

const (
	Unknown Format = iota
	Auto
	PNG
	JPEG
	WEBP
	GIF
	MONO
)

const (
	MIMEPNG  = "image/png"
	MIMEJPEG = "image/jpeg"
	MIMEWEBP = "image/webp"
	MIMEGIF  = "image/gif"
)

var mimeList = []string{MIMEPNG, MIMEWEBP, MIMEJPEG, MIMEGIF}

func MIMEList() []string {
	return mimeList
}
