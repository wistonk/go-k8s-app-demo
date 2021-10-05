ROM golang:alpine

WORKDIR /app
COPY . /app

RUN go build -o main .

CMD ["/app/main"]