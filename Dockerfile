ARG CADDY_VER=2.6.3

FROM golang:1.20-bullseye AS builder
ARG TS_VER=1.36.1

RUN go install \
    tailscale.com/cmd/get-authkey@v$TS_VER \
    tailscale.com/cmd/containerboot@v$TS_VER \
    tailscale.com/cmd/tailscale@v$TS_VER \
    tailscale.com/cmd/tailscaled@v$TS_VER

FROM caddy:${CADDY_VER} AS caddy

FROM debian:bullseye-slim

RUN apt update && \
    apt install -y --no-install-recommends ca-certificates jq &&\
    apt clean

VOLUME /var/lib/tailscale
COPY --from=builder /go/bin/* /usr/local/bin/
COPY --from=caddy /usr/bin/caddy /usr/local/bin/
COPY ./app.sh /

CMD ["/app.sh"]
