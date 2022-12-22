# Build Stage
FROM fuzzers/cargo-fuzz:0.11.0 AS builder

## Add source code to the build stage.
ADD . /repo
WORKDIR /repo

RUN cd fuzz && cargo fuzz build

# Package Stage
FROM ubuntu:20.04

## TODO: Change <Path in Builder Stage>
COPY --from=builder /repo/fuzz/target/x86_64-unknown-linux-gnu/release/fuzz_reader /
