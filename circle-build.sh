#!/bin/sh

set -e
cd /opt/gopath/src/github.com/redsift/go-render
glide install
go install -ldflags "-X main.Timestamp=`date -u '+%Y-%m-%d_%I:%M:%S%p'` -X main.Tag=$TAG -X main.Commit=$COMMIT" github.com/redsift/go-render/render
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

echo "ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/mesa/:/usr/lib/x86_64-linux-gnu/mesa-egl/ DISPLAY=:1 LIBGL_ALWAYS_INDIRECT=1" >> ./build/Dockerfile