#!/bin/sh

set -e
cd /opt/gopath/src/github.com/redsift/go-render
glide install
go install github.com/redsift/go-render/render
go test github.com/redsift/go-render

cp /opt/gopath/bin/render /usr/local/bin/render

mkdir -p build

dockerize -n -o ./build -e /usr/local/bin/render-xvfb --filetools \
                /usr/local/bin/render \
                /usr/bin/execlineb \
                /bin/background \
                /bin/foreground \
                /bin/kill \
                /bin/importas \
                /bin/exit \
                /usr/bin/Xvfb \
                /usr/bin/ldd \
                /bin/bash \
                /usr/local/bin/render-xvfb