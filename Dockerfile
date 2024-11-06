FROM golang:1.22.5 AS builder

WORKDIR /usr/src/app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /usr/local/bin/my_app ./

FROM postgres:alpine

COPY --from=builder /usr/local/bin/my_app /usr/local/bin/my_app

COPY tracker.db /usr/src/app/tracker.db

ENV POSTGRES_USER=myuser
ENV POSTGRES_PASSWORD=mypassword
ENV POSTGRES_DB=mydatabase

WORKDIR /usr/src/app

CMD ["sh", "-c", "docker-entrypoint.sh postgres & sleep 3 && /usr/local/bin/my_app"]