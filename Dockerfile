FROM ubuntu:16.04
MAINTAINER Rahul Powar email: rahul@redsift.io version: 1.1.102

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y lsb-release unzip openssl ca-certificates curl rsync gettext-base software-properties-common python-software-properties \
    	iputils-ping dnsutils build-essential libtool autoconf git dialog man python-pip \
    	libwebkit2gtk-4.0-dev libmagickwand-dev xvfb x11-utils && \
    	pip install dockerize && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GO_VERSION=1.6.2 GLIDE=0.13.1

# Go ENV vars
ENV GOPATH=/opt/gopath PATH=$PATH:/usr/local/go/bin

RUN cd /tmp && \
	curl -O https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz && \
	tar xvf go$GO_VERSION.linux-amd64.tar.gz > /dev/null && \
	mv go /usr/local && \
	rm -Rf /tmp/* && \
	mkdir -p $GOPATH && \
	go env GOROOT && go version

# Add the webp mime type as it seems to be missing
RUN echo -e "\nimage/webp webp" >> /etc/mime.types

# Cleanup default cron tasks
RUN rm -f /etc/cron.hourly/* /etc/cron.daily/* /etc/cron.weekly/*  /etc/cron.monthly/*

# Install glide for Go dependency management
RUN cd /tmp && \
	curl -L https://github.com/Masterminds/glide/releases/download/$GLIDE/glide-$GLIDE-linux-amd64.tar.gz -o glide.tar.gz && \
	tar -xf glide.tar.gz && \
	cp /tmp/linux-amd64/glide /usr/local/bin

# Fix for ubuntu to ensure /etc/default/locale is present
RUN update-locale

# Change the onetime and fixup stage to terminate on error
# Xvfb display number set to 1
# Prevent libGL errors with indirect mode http://unix.stackexchange.com/questions/1437/what-does-libgl-always-indirect-1-actually-do
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 DISPLAY=:1 LIBGL_ALWAYS_INDIRECT=1

# S6 default entry point is the init added from the overlay
ENTRYPOINT [ "/init" ]

WORKDIR /opt/gopath/

# Copy S6 & App
COPY root /
