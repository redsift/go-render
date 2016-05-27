# This is built from a temporary container on CI
# This could be stripped down

FROM go-render-build
MAINTAINER Rahul Powar email: rahul@redsift.io version: 1.1.102

ENTRYPOINT [ "/usr/local/bin/render-xvfb" ]

# Copy built binary
COPY root /