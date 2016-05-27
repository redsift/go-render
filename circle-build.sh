#!/bin/sh

set -e
cd /opt/gopath/src/github.com/redsift/go-render
glide install
go install -ldflags "-X main.Timestamp=`date -u '+%Y-%m-%d_%I:%M:%S%p'` -X main.Tag=$TAG -X main.Commit=$COMMIT" github.com/redsift/go-render/render
/opt/gopath/bin/render --version
go test github.com/redsift/go-render

cp /opt/gopath/bin/render /usr/local/bin/render

mkdir -p build/tmp

dockerize -n -o ./build -e /usr/local/bin/render-xvfb --filetools \
                /usr/local/bin/render \
                /usr/bin/execlineb \
                /bin/background \
                /bin/foreground \
                /bin/kill \
                /bin/importas \
                /bin/exit \
                /usr/bin/Xvfb \
                /bin/sh \
                /usr/bin/xkbcomp \
                /usr/share/X11/xkb/rules/evdev \
                /usr/lib/x86_64-linux-gnu/dri/swrast_dri.so \
                /usr/lib/xorg/protocol.txt \
                /usr/lib/x86_64-linux-gnu/libdrm_nouveau.so.2 \
                /usr/lib/x86_64-linux-gnu/libdrm_radeon.so.1 \
                /usr/lib/x86_64-linux-gnu/libdrm_amdgpu.so.1 \
                /usr/lib/x86_64-linux-gnu/libelf.so.1 \
                /usr/lib/x86_64-linux-gnu/libLLVM-3.8.so.1 \
                /usr/lib/x86_64-linux-gnu/libedit.so.2 \
                /lib/x86_64-linux-gnu/libbsd.so.0 \
                /usr/bin/ldd \
                /sbin/ldconfig.real \
                /etc/ld.so.conf \
                /etc/ld.so.conf.d/fakeroot-x86_64-linux-gnu.conf \
                /etc/ld.so.conf.d/libc.conf \
                /etc/ld.so.conf.d/x86_64-linux-gnu.conf \
                /etc/ld.so.conf.d/x86_64-linux-gnu_EGL.conf \
                /etc/ld.so.conf.d/x86_64-linux-gnu_GL.conf \
                /bin/bash \
                /usr/local/bin/render-xvfb

#LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/mesa/:/usr/lib/x86_64-linux-gnu/mesa-egl/

echo "ENV DISPLAY=:1 LIBGL_ALWAYS_INDIRECT=1 \nRUN /sbin/ldconfig.real" >> ./build/Dockerfile



