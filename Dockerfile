<<<<<<< c91b7c102591cac31fa35dbb9dfd6ab31da5e4fa
FROM golang:1.27-alpine3.24@sha256:8a5910f31396cd4d89662f56c68b3ae31d374308270a1c3bd96672ee5ed43414 AS go-builder
=======
FROM node:24-bookworm-slim@sha256:55fb5f5a527ea2c5c4a95f963e48ef90aa38c7b346054fdc8ee9957a2b55d205

ENV MARKDOWNLINT_CLI_VERSION=v0.50.0

RUN npm install -g "markdownlint-cli@$MARKDOWNLINT_CLI_VERSION"
>>>>>>> e82b781e8865cb734917fdfb8157d49d91271775

ENV REVIEWDOG_VERSION=v0.21.3

RUN apk add --no-cache git \
    && git clone --depth 1 --branch ${REVIEWDOG_VERSION} https://github.com/reviewdog/reviewdog.git /reviewdog \
    && cd /reviewdog \
    && go mod edit -require=golang.org/x/crypto@v0.45.0 \
    && go mod tidy \
    && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o reviewdog ./cmd/reviewdog

FROM node:26-alpine3.24@sha256:0b36e8c136b94cd4fcf02188228e76c31ad5872eef3fec8cbd2eee500cfd9e80
ENV MARKDOWNLINT_CLI_VERSION=v0.49.1
RUN npm install -g "markdownlint-cli@$MARKDOWNLINT_CLI_VERSION"

RUN apk upgrade --no-cache \
    && apk add --no-cache \
        ca-certificates \
        git \
        jq \
        wget \
        curl

COPY --from=go-builder /reviewdog/reviewdog /usr/local/bin/reviewdog

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD []
