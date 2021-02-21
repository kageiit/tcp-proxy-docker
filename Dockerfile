FROM alpine

RUN apk --no-cache add bash curl socat

COPY tcp-proxy.sh /usr/bin/tcp-proxy

ENTRYPOINT ["tcp-proxy"]
