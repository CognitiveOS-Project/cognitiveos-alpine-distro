ARG CGO_ENABLED=0
FROM golang:1.25-alpine AS builder
ARG CGO_ENABLED
ENV CGO_ENABLED=${CGO_ENABLED}
RUN sed -i 's/#http/http/g' /etc/apk/repositories && apk update
RUN apk add --no-cache git ca-certificates cmake build-base make
WORKDIR /src
COPY . .
RUN make docker.build

FROM alpine:edge
RUN sed -i 's/#http/http/g' /etc/apk/repositories && apk update
RUN apk add --no-cache \
    alpine-base busybox openrc linux-rpi \
    raspberrypi-bootloader raspberrypi-firmware \
    alsa-utils alsa-lib \
    iw wpa_supplicant dhcpcd \
    libgpiod kbd mpv \
    dosfstools e2fsprogs squashfs-tools acpid \
    fbv fbi gpiod-tools
COPY --from=builder /out/ /
ENTRYPOINT ["/usr/local/bin/cognitiveos-cli"]
