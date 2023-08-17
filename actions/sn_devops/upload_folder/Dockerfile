FROM alpine:3.18
RUN apk --no-cache add curl jq bash
RUN apk upgrade libssl3 libcrypto3
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
