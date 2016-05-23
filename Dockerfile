FROM ubuntu:14.04
MAINTAINER Rahul Powar email: rahul@redsift.io version: 1.1.101

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y lsb-release unzip openssl ca-certificates curl rsync gettext-base software-properties-common python-software-properties \
    	iputils-ping dnsutils build-essential libtool autoconf git dialog man \
    	libwebkit2gtk-3.0-dev libmagickwand-dev xvfb && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GO_VERSION=1.6.2 GLIDE=0.10.2

# Go ENV vars
ENV GOPATH=/opt/gopath PATH=$PATH:/usr/local/go/bin

RUN cd /tmp && \
	curl -O https://storage.googleapis.com/golang/go$GO_VERSION.linux-amd64.tar.gz && \
	tar xvf go$GO_VERSION.linux-amd64.tar.gz && \
	mv go /usr/local && \
	rm -Rf /tmp/* && \
	go env GOROOT && go version

# Cleanup default cron tasks
RUN rm -f /etc/cron.hourly/* /etc/cron.daily/* /etc/cron.weekly/*  /etc/cron.monthly/*

# Install glide for Go dependency management
RUN cd /tmp && \
	curl -L https://github.com/Masterminds/glide/releases/download/$GLIDE/glide-$GLIDE-linux-amd64.tar.gz -o glide.tar.gz && \
	tar -xf glide.tar.gz && \
	cp /tmp/linux-amd64/glide /usr/local/bin

COPY root /
	
# Fix for ubuntu to ensure /etc/default/locale is present
RUN update-locale

# Change the onetime and fixup stage to terminate on error
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

# S6 default entry point is the init added from the overlay
ENTRYPOINT [ "/init" ]	