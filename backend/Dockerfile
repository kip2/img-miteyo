# First: For build
FROM rust:1.87 as builder
WORKDIR /app

ARG DATABASE_URL
ENV DATABASE_URL=${DATABASE_URL}

COPY . .

RUN apt-get update && apt-get install -y pkg-config libssl-dev

RUN cargo build --release

# Second: For run server
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/target/release/app ./target/release/app

EXPOSE 8080
ENTRYPOINT [ "./target/release/app" ]
