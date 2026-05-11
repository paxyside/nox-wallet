FROM dart:stable AS dart

FROM golang:1.26

ENV BUF_VERSION=1.50.1 \
    PROTOC_GEN_GO_VERSION=v1.36.10 \
    PROTOC_GEN_GO_GRPC_VERSION=v1.5.1

RUN apt-get update && apt-get install -y --no-install-recommends curl git unzip && rm -rf /var/lib/apt/lists/*

# Install buf
RUN curl -sSL "https://github.com/bufbuild/buf/releases/download/v${BUF_VERSION}/buf-Linux-x86_64" \
      -o /usr/local/bin/buf && \
    chmod +x /usr/local/bin/buf

# Install protoc-gen-go and protoc-gen-go-grpc
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@${PROTOC_GEN_GO_VERSION} && \
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@${PROTOC_GEN_GO_GRPC_VERSION}

# Copy Dart SDK from official image
COPY --from=dart /usr/lib/dart /usr/lib/dart
ENV PATH="/usr/lib/dart/bin:/root/.pub-cache/bin:${PATH}"

RUN dart pub global activate protoc_plugin

WORKDIR /workspace

ENTRYPOINT ["buf"]
