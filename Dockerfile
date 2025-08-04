FROM golang:1.23-alpine@sha256:9b07790bb99f0cba351ed7199a421b6281b0d84325647c83d009f6540f6ceb90 AS go-builder

ENV REVIEWDOG_VERSION=v0.20.3

RUN apk add --no-cache git \
    && git clone --depth 1 --branch ${REVIEWDOG_VERSION} https://github.com/reviewdog/reviewdog.git /reviewdog \
    && cd /reviewdog \
    && go mod edit -require=golang.org/x/crypto@v0.35.0 \
    && go mod tidy \
    && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o reviewdog ./cmd/reviewdog

FROM node:24-alpine@sha256:6a61dbdf1dd6adbfcf0c09237f8f0f7a101b479b0491f2e49b114e55f027ba16

ENV MARKDOWNLINT_CLI_VERSION=v0.42.0
RUN npm install -g "markdownlint-cli@$MARKDOWNLINT_CLI_VERSION"

RUN apk add --no-cache \
        ca-certificates \
        git \
        wget \
        curl

COPY --from=go-builder /reviewdog/reviewdog /usr/local/bin/reviewdog

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
