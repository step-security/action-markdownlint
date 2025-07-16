FROM golang:1.24-alpine@sha256:48ee313931980110b5a91bbe04abdf640b9a67ca5dea3a620f01bacf50593396 AS go-builder

ENV REVIEWDOG_VERSION=v0.20.3

RUN apk add --no-cache git \
    && git clone --depth 1 --branch ${REVIEWDOG_VERSION} https://github.com/reviewdog/reviewdog.git /reviewdog \
    && cd /reviewdog \
    && go mod edit -require=golang.org/x/crypto@v0.35.0 \
    && go mod tidy \
    && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o reviewdog ./cmd/reviewdog

FROM node:22-alpine@sha256:fc3e945f920b7e3000cd1af86c4ae406ec70c72f328b667baf0f3a8910d69eed

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
