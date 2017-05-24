FROM aarch64/debian:jessie

# Add build-dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		bash \
		bzip2 \
		bzr \
		ca-certificates \
		curl \
		g++ \
		gcc \
		git \
		libc6-dev \
		make \
		mercurial \
		openssh-client \
		pkg-config \
		procps \
		subversion \
		wget \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.8.2

# https://github.com/hypriot/golang-armbuilds
# we need this env var for the Go bootstrap build process
ENV GOROOT_BOOTSTRAP $HOME/go1.5
# install a pre-compiled Go 1.5.x tarball to bootstrap on ARM64
ENV GO_BOOTSTRAP_VERSION 1.5.1
RUN rm -fr "$GOROOT_BOOTSTRAP" \
	&& mkdir -p "$GOROOT_BOOTSTRAP" \
	&& curl -sSL "https://github.com/hypriot/golang-armbuilds/releases/download/v${GO_BOOTSTRAP_VERSION}/go-linux-arm64-bootstrap.tbz" \
	| tar -xj -C "$GOROOT_BOOTSTRAP" --strip-components=1

# fetch Go source tarball
RUN curl -sSL "https://storage.googleapis.com/golang/go${GOLANG_VERSION}.src.tar.gz" | tar xz -C /usr/local

# now compile Go and package
RUN cd /usr/local/go/src \
	&& ./make.bash 2>&1

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/
