FROM golang:1.16-alpine as builder

COPY . /src/
WORKDIR /src

EXPOSE 8888

RUN go build

FROM alpine

COPY --from=builder /src/go-k8s-app-demo /

ENTRYPOINT ["/go-k8s-app-demo"]