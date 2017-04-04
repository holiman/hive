# This dockerfile is the root "shell" around the entire hive container ecosystem.
#
# Its goal is to containerize everything that hive does within a single mega
# container, preventing any leakage of junk (be that file system, docker images
# and/or containers, network traffic) into the host system.
#
# To this effect is runs its own docker engine within, executing the entire hive
# test suite inside. The data workspace of the internal docker engine needs to
# be mounted outside to allow proper image caching. Further, to allow running a
# docker instance internally, this shell must be started in privileged mode.
#
# Callers need to:
#   - Bind /var/lib/docker to an external volume for cache reuse
#   - Forward UID envvar to reown docker and hive generated files
#   - Run with --privileged to allow docker-in-docker containers
FROM docker:dind

# Configure the container for building hive
RUN apk add --update musl-dev bash go python && rm -rf /var/cache/apk/*
ENV GOPATH /gopath
ENV PATH   $GOPATH/bin:$PATH

# Inject and build the hive dependencies (modified very rarely, cache builds)
ADD vendor $GOPATH/src/github.com/karalabe/hive/vendor
RUN (cd $GOPATH/src/github.com/karalabe/hive && go install ./...)

# Inject and build hive itself (modified during hive dev only, cache builds)
ADD *.go $GOPATH/src/github.com/karalabe/hive/

WORKDIR $GOPATH/src/github.com/karalabe/hive
RUN go install

# Inject all other runtime resources (modified most frequently)
COPY . $GOPATH/src/github.com/karalabe/hive
RUN chmod +x hivetesting.sh && chmod +x hivetesting.sh
ENTRYPOINT ["./hivetesting.sh"]