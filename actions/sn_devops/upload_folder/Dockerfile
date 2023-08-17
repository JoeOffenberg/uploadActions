FROM alpine:3.18
RUN apk --no-cache add curl jq bash
RUN apk upgrade libssl3 libcrypto3
RUN wget https://github.com/sclevine/yj/releases/download/v5.1.0/yj-linux-amd64
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh yj-linux-amd64
ENTRYPOINT ["/entrypoint.sh"]
