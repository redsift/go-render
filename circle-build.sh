#!/bin/sh

set -e
cd /opt/gopath/src/github.com/redsift/go-render
glide install
go install -ldflags "-X version.Tag `date -u '+%Y-%m-%d_%I:%M:%S%p'` -X version.Commit GITHASH" github.com/redsift/go-render/render
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

echo "ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/mesa/" >> ./build/Dockerfile