ARG CGO_ENABLED=0
FROM golang:1.25-alpine@sha256:56961d79ea8129efddcc0b8643fd8a5416b4e6228cfd477e3fd61deb2672c587 AS builder
ARG CGO_ENABLED
ENV CGO_ENABLED=${CGO_ENABLED}
RUN sed -i 's/#http/http/g' /etc/apk/repositories && apk update
RUN apk add --no-cache git ca-certificates cmake build-base make
WORKDIR /src
COPY . .
RUN make docker.build

FROM alpine:edge@sha256:9a341ff2287c54b86425cbee0141114d811ae69d88a36019087be6d896cef241
COPY scripts/bootstrap-docker-release.sh /usr/local/bin/
COPY packages.edge-aarch64 /tmp/packages
RUN bootstrap-docker-release.sh /tmp/packages
COPY --from=builder /out/ /
ENTRYPOINT ["/usr/local/bin/cognitiveos-cli"]
