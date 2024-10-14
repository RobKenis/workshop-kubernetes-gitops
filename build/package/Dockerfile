FROM golang:1.23 as builder

WORKDIR /build

COPY go.mod .
COPY go.sum .
RUN go mod download

COPY cmd cmd

RUN CGO_ENABLED=0 GOOS=linux go build -o server cmd/server.go

FROM scratch

WORKDIR /app

COPY --from=builder /build/server server

EXPOSE 8080

CMD ["/app/server"]
