#!/bin/sh

set -e
cd /opt/gopath/src/github.com/redsift/go-render
glide install
go install github.com/redsift/go-render/render
go test github.com/redsift/go-render
