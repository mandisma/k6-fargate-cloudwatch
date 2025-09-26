# Build stage: compile k6 with the statsd extension
FROM golang:1.24.7 AS builder

WORKDIR /build
RUN go install go.k6.io/xk6@latest

# Build a k6 binary with the extension
RUN xk6 build --with github.com/LeonAdato/xk6-output-statsd

# Final stage: set up the k6 environment
FROM alpine:3.17

# Install required dependencies
RUN apk add --no-cache ca-certificates \
    && update-ca-certificates

# Copy the custom k6 binary from the builder stage
COPY --from=builder /build/k6 /usr/local/bin/k6

# Make it executable
RUN chmod +x /usr/local/bin/k6

# Set up the test environment
ENV SCRIPT=smoke.js
COPY ./test /test
WORKDIR /test

# Override the entry point
ENTRYPOINT []
CMD ["sh", "-c", "K6_STATSD_TAG_BLOCKLIST=vu,iter,url,expected_response,method,name,proto,scenario,status,tls_version K6_STATSD_ENABLE_TAGS=true k6 run -o output-statsd $SCRIPT"]