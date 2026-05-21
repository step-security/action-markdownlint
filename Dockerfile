FROM golang:1.26.3-alpine3.23@sha256:91eda9776261207ea25fd06b5b7fed8d397dd2c0a283e77f2ab6e91bfa71079d AS go-builder

ENV REVIEWDOG_VERSION=v0.21.0

RUN apk add --no-cache git \
    && git clone --depth 1 --branch ${REVIEWDOG_VERSION} https://github.com/reviewdog/reviewdog.git /reviewdog \
    && cd /reviewdog \
    && go mod edit -require=golang.org/x/crypto@v0.45.0 \
    && go mod tidy \
    && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o reviewdog ./cmd/reviewdog

FROM node:26.2.0-alpine3.23@sha256:7c6af15abe4e3de859690e7db171d0d711bf37d27528eddfe625b2fe89e097f8
ENV MARKDOWNLINT_CLI_VERSION=v0.48.0
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
