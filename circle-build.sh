#!/bin/sh

set -e
cd /opt/gopath/src/github.com/redsift/go-render
glide install
go install -ldflags "-X main.Timestamp=`date -u '+%Y-%m-%d_%I:%M:%S%p'` -X main.Tag=$TAG -X main.Commit=$COMMIT" github.com/redsift/go-render/render
/opt/gopath/bin/render --version
go test github.com/redsift/go-render

cp /opt/gopath/bin/render /usr/local/bin/render

mkdir -p build/root
mkdir -p build/tmp
mkdir -p build/var/lib
mkdir -p build/var/cache
mkdir -p build/usr/local/share/fonts

mkdir -p build/etc
cp /etc/drirc /etc/gai.conf /etc/localtime /etc/services /etc/locale.alias build/etc/.

mkdir -p build/etc/gtk-3.0/
cp /etc/gtk-3.0/settings.ini build/etc/gtk-3.0/settings.ini

mkdir -p build/etc/ssl/certs/
cp /etc/ssl/certs/ca-certificates.crt build/etc/ssl/certs/ca-certificates.crt

mkdir -p build/etc/fonts/
cp -R /etc/fonts build/etc/

mkdir -p build/usr/share/X11/xkb
cp -R /usr/share/X11/xkb build/usr/share/X11/

mkdir -p build/usr/share/fonts
cp -R /usr/share/fonts build/usr/share/

mkdir -p build/usr/share/locale
cp /usr/share/locale/locale.alias build/usr/share/locale/locale.alias

mkdir -p build/usr/share/glib-2.0/schemas
cp /usr/share/glib-2.0/schemas/gschemas.compiled build/usr/share/glib-2.0/schemas/gschemas.compiled

mkdir -p build/usr/share/poppler/cMap
cp -R /usr/share/poppler/cMap build/usr/share/poppler/

mkdir -p build/usr/share/zoneinfo
cp -R /usr/share/zoneinfo build/usr/share/

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
                /bin/dash \
                /usr/bin/ldd \
                /sbin/ldconfig.real \
                /etc/ld.so.conf \
                /etc/ld.so.conf.d/fakeroot-x86_64-linux-gnu.conf \
                /etc/ld.so.conf.d/libc.conf \
                /etc/ld.so.conf.d/x86_64-linux-gnu.conf \
                /etc/ld.so.conf.d/x86_64-linux-gnu_EGL.conf \
                /etc/ld.so.conf.d/x86_64-linux-gnu_GL.conf \
                /bin/bash \
                /usr/local/bin/render-xvfb \
                /lib/x86_64-linux-gnu/libaudit.so.1 \
                /lib/x86_64-linux-gnu/libaudit.so.1.0.0 \
                /lib/x86_64-linux-gnu/libbsd.so.0 \
                /lib/x86_64-linux-gnu/libbsd.so.0.8.2 \
                /lib/x86_64-linux-gnu/libbz2.so.1.0 \
                /lib/x86_64-linux-gnu/libbz2.so.1.0.4 \
                /lib/x86_64-linux-gnu/libc-2.23.so \
                /lib/x86_64-linux-gnu/libc.so.6 \
                /lib/x86_64-linux-gnu/libdbus-1.so.3 \
                /lib/x86_64-linux-gnu/libdbus-1.so.3.14.6 \
                /lib/x86_64-linux-gnu/libdl-2.23.so \
                /lib/x86_64-linux-gnu/libdl.so.2 \
                /lib/x86_64-linux-gnu/libexpat.so.1 \
                /lib/x86_64-linux-gnu/libexpat.so.1.6.0 \
                /lib/x86_64-linux-gnu/libgcc_s.so.1 \
                /lib/x86_64-linux-gnu/libgcrypt.so.20 \
                /lib/x86_64-linux-gnu/libgcrypt.so.20.0.5 \
                /lib/x86_64-linux-gnu/libglib-2.0.so.0 \
                /lib/x86_64-linux-gnu/libglib-2.0.so.0.4800.0 \
                /lib/x86_64-linux-gnu/libgpg-error.so.0 \
                /lib/x86_64-linux-gnu/libgpg-error.so.0.17.0 \
                /lib/x86_64-linux-gnu/liblzma.so.5 \
                /lib/x86_64-linux-gnu/liblzma.so.5.0.0 \
                /lib/x86_64-linux-gnu/libm-2.23.so \
                /lib/x86_64-linux-gnu/libm.so.6 \
                /lib/x86_64-linux-gnu/libnss_dns-2.23.so \
                /lib/x86_64-linux-gnu/libnss_dns.so.2 \
                /lib/x86_64-linux-gnu/libnss_files-2.23.so \
                /lib/x86_64-linux-gnu/libnss_files.so.2 \
                /lib/x86_64-linux-gnu/libpcre.so.3 \
                /lib/x86_64-linux-gnu/libpcre.so.3.13.2 \
                /lib/x86_64-linux-gnu/libpng12.so.0 \
                /lib/x86_64-linux-gnu/libpng12.so.0.54.0 \
                /lib/x86_64-linux-gnu/libprocps.so.4 \
                /lib/x86_64-linux-gnu/libprocps.so.4.0.0 \
                /lib/x86_64-linux-gnu/libpthread-2.23.so \
                /lib/x86_64-linux-gnu/libpthread.so.0 \
                /lib/x86_64-linux-gnu/libresolv-2.23.so \
                /lib/x86_64-linux-gnu/libresolv.so.2 \
                /lib/x86_64-linux-gnu/librt-2.23.so \
                /lib/x86_64-linux-gnu/librt.so.1 \
                /lib/x86_64-linux-gnu/libselinux.so.1 \
                /lib/x86_64-linux-gnu/libsystemd.so.0 \
                /lib/x86_64-linux-gnu/libsystemd.so.0.14.0 \
                /lib/x86_64-linux-gnu/libtinfo.so.5 \
                /lib/x86_64-linux-gnu/libtinfo.so.5.9 \
                /lib/x86_64-linux-gnu/libz.so.1 \
                /lib/x86_64-linux-gnu/libz.so.1.2.8 \
                /usr/bin/xkbcomp \
                /usr/lib/x86_64-linux-gnu/dri/swrast_dri.so \
                /usr/lib/x86_64-linux-gnu/gconv/gconv-modules.cache \
                /usr/lib/x86_64-linux-gnu/gdk-pixbuf-2.0/2.10.0/loaders.cache \
                /usr/lib/x86_64-linux-gnu/gio/modules \
                /usr/lib/x86_64-linux-gnu/gio/modules/giomodule.cache \
                /usr/lib/x86_64-linux-gnu/gio/modules/libdconfsettings.so \
                /usr/lib/x86_64-linux-gnu/gio/modules/libgiognomeproxy.so \
                /usr/lib/x86_64-linux-gnu/gio/modules/libgiognutls.so \
                /usr/lib/x86_64-linux-gnu/gio/modules/libgiolibproxy.so \
                /usr/lib/x86_64-linux-gnu/libLLVM-3.8.so.1 \
                /usr/lib/x86_64-linux-gnu/libX11-xcb.so.1 \
                /usr/lib/x86_64-linux-gnu/libX11-xcb.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libX11.so.6 \
                /usr/lib/x86_64-linux-gnu/libX11.so.6.3.0 \
                /usr/lib/x86_64-linux-gnu/libXau.so.6 \
                /usr/lib/x86_64-linux-gnu/libXau.so.6.0.0 \
                /usr/lib/x86_64-linux-gnu/libXcomposite.so.1 \
                /usr/lib/x86_64-linux-gnu/libXcomposite.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libXcursor.so.1 \
                /usr/lib/x86_64-linux-gnu/libXcursor.so.1.0.2 \
                /usr/lib/x86_64-linux-gnu/libXdamage.so.1 \
                /usr/lib/x86_64-linux-gnu/libXdamage.so.1.1.0 \
                /usr/lib/x86_64-linux-gnu/libXdmcp.so.6 \
                /usr/lib/x86_64-linux-gnu/libXdmcp.so.6.0.0 \
                /usr/lib/x86_64-linux-gnu/libXext.so.6 \
                /usr/lib/x86_64-linux-gnu/libXext.so.6.4.0 \
                /usr/lib/x86_64-linux-gnu/libXfixes.so.3 \
                /usr/lib/x86_64-linux-gnu/libXfixes.so.3.1.0 \
                /usr/lib/x86_64-linux-gnu/libXfont.so.1 \
                /usr/lib/x86_64-linux-gnu/libXfont.so.1.4.1 \
                /usr/lib/x86_64-linux-gnu/libXi.so.6 \
                /usr/lib/x86_64-linux-gnu/libXi.so.6.1.0 \
                /usr/lib/x86_64-linux-gnu/libXinerama.so.1 \
                /usr/lib/x86_64-linux-gnu/libXinerama.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libXrandr.so.2 \
                /usr/lib/x86_64-linux-gnu/libXrandr.so.2.2.0 \
                /usr/lib/x86_64-linux-gnu/libXrender.so.1 \
                /usr/lib/x86_64-linux-gnu/libXrender.so.1.3.0 \
                /usr/lib/x86_64-linux-gnu/libXxf86vm.so.1 \
                /usr/lib/x86_64-linux-gnu/libXxf86vm.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libatk-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libatk-1.0.so.0.21809.1 \
                /usr/lib/x86_64-linux-gnu/libatk-bridge-2.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libatk-bridge-2.0.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libatspi.so.0 \
                /usr/lib/x86_64-linux-gnu/libatspi.so.0.0.1 \
                /usr/lib/x86_64-linux-gnu/libboost_filesystem.so.1.58.0 \
                /usr/lib/x86_64-linux-gnu/libboost_system.so.1.58.0 \
                /usr/lib/x86_64-linux-gnu/libcairo-gobject.so.2 \
                /usr/lib/x86_64-linux-gnu/libcairo-gobject.so.2.11400.6 \
                /usr/lib/x86_64-linux-gnu/libcairo.so.2 \
                /usr/lib/x86_64-linux-gnu/libcairo.so.2.11400.6 \
                /usr/lib/x86_64-linux-gnu/libdatrie.so.1 \
                /usr/lib/x86_64-linux-gnu/libdatrie.so.1.3.3 \
                /usr/lib/x86_64-linux-gnu/libdbus-glib-1.so.2 \
                /usr/lib/x86_64-linux-gnu/libdbus-glib-1.so.2.3.3 \
                /usr/lib/x86_64-linux-gnu/libdrm.so.2 \
                /usr/lib/x86_64-linux-gnu/libdrm.so.2.4.0 \
                /usr/lib/x86_64-linux-gnu/libdrm_amdgpu.so.1 \
                /usr/lib/x86_64-linux-gnu/libdrm_amdgpu.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libdrm_nouveau.so.2 \
                /usr/lib/x86_64-linux-gnu/libdrm_nouveau.so.2.0.0 \
                /usr/lib/x86_64-linux-gnu/libdrm_radeon.so.1 \
                /usr/lib/x86_64-linux-gnu/libdrm_radeon.so.1.0.1 \
                /usr/lib/x86_64-linux-gnu/libedit.so.2 \
                /usr/lib/x86_64-linux-gnu/libedit.so.2.0.53 \
                /usr/lib/x86_64-linux-gnu/libelf-0.165.so \
                /usr/lib/x86_64-linux-gnu/libelf.so.1 \
                /usr/lib/x86_64-linux-gnu/libenchant.so.1 \
                /usr/lib/x86_64-linux-gnu/libenchant.so.1.6.0 \
                /usr/lib/x86_64-linux-gnu/libepoxy.so.0 \
                /usr/lib/x86_64-linux-gnu/libepoxy.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libffi.so.6 \
                /usr/lib/x86_64-linux-gnu/libffi.so.6.0.4 \
                /usr/lib/x86_64-linux-gnu/libfontconfig.so.1 \
                /usr/lib/x86_64-linux-gnu/libfontconfig.so.1.9.0 \
                /usr/lib/x86_64-linux-gnu/libfontenc.so.1 \
                /usr/lib/x86_64-linux-gnu/libfontenc.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libfreetype.so.6 \
                /usr/lib/x86_64-linux-gnu/libfreetype.so.6.12.1 \
                /usr/lib/x86_64-linux-gnu/libgbm.so.1 \
                /usr/lib/x86_64-linux-gnu/libgbm.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libgdk-3.so.0 \
                /usr/lib/x86_64-linux-gnu/libgdk-3.so.0.1800.9 \
                /usr/lib/x86_64-linux-gnu/libgdk_pixbuf-2.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgdk_pixbuf-2.0.so.0.3200.2 \
                /usr/lib/x86_64-linux-gnu/libgeoclue.so.0 \
                /usr/lib/x86_64-linux-gnu/libgeoclue.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgio-2.0.so.0.4800.0 \
                /usr/lib/x86_64-linux-gnu/libglapi.so.0 \
                /usr/lib/x86_64-linux-gnu/libglapi.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgmodule-2.0.so.0.4800.0 \
                /usr/lib/x86_64-linux-gnu/libgmp.so.10 \
                /usr/lib/x86_64-linux-gnu/libgmp.so.10.3.0 \
                /usr/lib/x86_64-linux-gnu/libgnutls.so.30 \
                /usr/lib/x86_64-linux-gnu/libgnutls.so.30.6.2 \
                /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0.4800.0 \
                /usr/lib/x86_64-linux-gnu/libgraphite2.so.3 \
                /usr/lib/x86_64-linux-gnu/libgraphite2.so.3.0.1 \
                /usr/lib/x86_64-linux-gnu/libgstapp-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgstapp-1.0.so.0.801.0 \
                /usr/lib/x86_64-linux-gnu/libgstaudio-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgstaudio-1.0.so.0.801.0 \
                /usr/lib/x86_64-linux-gnu/libgstbase-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgstbase-1.0.so.0.801.0 \
                /usr/lib/x86_64-linux-gnu/libgstfft-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgstfft-1.0.so.0.801.0 \
                /usr/lib/x86_64-linux-gnu/libgstpbutils-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgstpbutils-1.0.so.0.801.0 \
                /usr/lib/x86_64-linux-gnu/libgstreamer-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgstreamer-1.0.so.0.801.0 \
                /usr/lib/x86_64-linux-gnu/libgsttag-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgsttag-1.0.so.0.801.0 \
                /usr/lib/x86_64-linux-gnu/libgstvideo-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libgstvideo-1.0.so.0.801.0 \
                /usr/lib/x86_64-linux-gnu/libgtk-3.so.0 \
                /usr/lib/x86_64-linux-gnu/libgtk-3.so.0.1800.9 \
                /usr/lib/x86_64-linux-gnu/libharfbuzz-icu.so.0 \
                /usr/lib/x86_64-linux-gnu/libharfbuzz-icu.so.0.10000.1 \
                /usr/lib/x86_64-linux-gnu/libharfbuzz.so.0 \
                /usr/lib/x86_64-linux-gnu/libharfbuzz.so.0.10000.1 \
                /usr/lib/x86_64-linux-gnu/libhogweed.so.4 \
                /usr/lib/x86_64-linux-gnu/libhogweed.so.4.2 \
                /usr/lib/x86_64-linux-gnu/libhyphen.so.0 \
                /usr/lib/x86_64-linux-gnu/libhyphen.so.0.3.0 \
                /usr/lib/x86_64-linux-gnu/libicudata.so.55 \
                /usr/lib/x86_64-linux-gnu/libicudata.so.55.1 \
                /usr/lib/x86_64-linux-gnu/libicui18n.so.55 \
                /usr/lib/x86_64-linux-gnu/libicui18n.so.55.1 \
                /usr/lib/x86_64-linux-gnu/libicuuc.so.55 \
                /usr/lib/x86_64-linux-gnu/libicuuc.so.55.1 \
                /usr/lib/x86_64-linux-gnu/libidn.so.11 \
                /usr/lib/x86_64-linux-gnu/libidn.so.11.6.15 \
                /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.0.so.18 \
                /usr/lib/x86_64-linux-gnu/libjavascriptcoregtk-4.0.so.18.2.17 \
                /usr/lib/x86_64-linux-gnu/libjpeg.so.8 \
                /usr/lib/x86_64-linux-gnu/libjpeg.so.8.0.2 \
                /usr/lib/x86_64-linux-gnu/libmirclient.so.9 \
                /usr/lib/x86_64-linux-gnu/libmircommon.so.5 \
                /usr/lib/x86_64-linux-gnu/libmirprotobuf.so.3 \
                /usr/lib/x86_64-linux-gnu/libnettle.so.6 \
                /usr/lib/x86_64-linux-gnu/libnettle.so.6.2 \
                /usr/lib/x86_64-linux-gnu/libnotify.so.4 \
                /usr/lib/x86_64-linux-gnu/libnotify.so.4.0.0 \
                /usr/lib/x86_64-linux-gnu/liborc-0.4.so.0 \
                /usr/lib/x86_64-linux-gnu/liborc-0.4.so.0.25.0 \
                /usr/lib/x86_64-linux-gnu/libp11-kit.so.0 \
                /usr/lib/x86_64-linux-gnu/libp11-kit.so.0.1.0 \
                /usr/lib/x86_64-linux-gnu/libpango-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libpango-1.0.so.0.3800.1 \
                /usr/lib/x86_64-linux-gnu/libpangocairo-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libpangocairo-1.0.so.0.3800.1 \
                /usr/lib/x86_64-linux-gnu/libpangoft2-1.0.so.0 \
                /usr/lib/x86_64-linux-gnu/libpangoft2-1.0.so.0.3800.1 \
                /usr/lib/x86_64-linux-gnu/libpixman-1.so.0 \
                /usr/lib/x86_64-linux-gnu/libpixman-1.so.0.33.6 \
                /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9 \
                /usr/lib/x86_64-linux-gnu/libprotobuf-lite.so.9.0.1 \
                /usr/lib/x86_64-linux-gnu/libproxy.so.1 \
                /usr/lib/x86_64-linux-gnu/libproxy.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libsecret-1.so.0 \
                /usr/lib/x86_64-linux-gnu/libsecret-1.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libsoup-2.4.so.1 \
                /usr/lib/x86_64-linux-gnu/libsoup-2.4.so.1.7.0 \
                /usr/lib/x86_64-linux-gnu/libsqlite3.so.0 \
                /usr/lib/x86_64-linux-gnu/libsqlite3.so.0.8.6 \
                /usr/lib/x86_64-linux-gnu/libstdc++.so.6 \
                /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.21 \
                /usr/lib/x86_64-linux-gnu/libtasn1.so.6 \
                /usr/lib/x86_64-linux-gnu/libtasn1.so.6.5.1 \
                /usr/lib/x86_64-linux-gnu/libthai.so.0 \
                /usr/lib/x86_64-linux-gnu/libthai.so.0.2.4 \
                /usr/lib/x86_64-linux-gnu/libtxc_dxtn.so \
                /usr/lib/x86_64-linux-gnu/libtxc_dxtn_s2tc.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libwayland-client.so.0 \
                /usr/lib/x86_64-linux-gnu/libwayland-client.so.0.3.0 \
                /usr/lib/x86_64-linux-gnu/libwayland-cursor.so.0 \
                /usr/lib/x86_64-linux-gnu/libwayland-cursor.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libwayland-egl.so.1 \
                /usr/lib/x86_64-linux-gnu/libwayland-egl.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libwayland-server.so.0 \
                /usr/lib/x86_64-linux-gnu/libwayland-server.so.0.1.0 \
                /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.0.so.37 \
                /usr/lib/x86_64-linux-gnu/libwebkit2gtk-4.0.so.37.11.12 \
                /usr/lib/x86_64-linux-gnu/libwebp.so.5 \
                /usr/lib/x86_64-linux-gnu/libwebp.so.5.0.4 \
                /usr/lib/x86_64-linux-gnu/libxcb-dri2.so.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-dri2.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-dri3.so.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-dri3.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-glx.so.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-glx.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-present.so.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-present.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-render.so.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-render.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-shm.so.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-shm.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-sync.so.1 \
                /usr/lib/x86_64-linux-gnu/libxcb-sync.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-xfixes.so.0 \
                /usr/lib/x86_64-linux-gnu/libxcb-xfixes.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libxcb.so.1 \
                /usr/lib/x86_64-linux-gnu/libxcb.so.1.1.0 \
                /usr/lib/x86_64-linux-gnu/libxkbcommon.so.0 \
                /usr/lib/x86_64-linux-gnu/libxkbcommon.so.0.0.0 \
                /usr/lib/x86_64-linux-gnu/libxkbfile.so.1 \
                /usr/lib/x86_64-linux-gnu/libxkbfile.so.1.0.2 \
                /usr/lib/x86_64-linux-gnu/libxml2.so.2 \
                /usr/lib/x86_64-linux-gnu/libxml2.so.2.9.3 \
                /usr/lib/x86_64-linux-gnu/libxshmfence.so.1 \
                /usr/lib/x86_64-linux-gnu/libxshmfence.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/libxslt.so.1 \
                /usr/lib/x86_64-linux-gnu/libxslt.so.1.1.28 \
                /usr/lib/x86_64-linux-gnu/mesa-egl/libEGL.so.1 \
                /usr/lib/x86_64-linux-gnu/mesa-egl/libEGL.so.1.0.0 \
                /usr/lib/x86_64-linux-gnu/mesa/libGL.so.1 \
                /usr/lib/x86_64-linux-gnu/mesa/libGL.so.1.2.0 \
                /usr/lib/xorg/protocol.txt

# Ensure there are no broken links
BROKEN=$(find build -xtype l)
if [ -z "$BROKEN" ]
then
	echo "All symlinks ok"
else
	echo "Links broken $BROKEN"
	exit 1
fi

#LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu/mesa/:/usr/lib/x86_64-linux-gnu/mesa-egl/

echo "ENV DISPLAY=:1 LIBGL_ALWAYS_INDIRECT=1 \nRUN /sbin/ldconfig.real" >> ./build/Dockerfile



