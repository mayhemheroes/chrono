FROM --platform=linux/amd64 ubuntu:22.04 AS builder

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl build-essential

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain nightly
ENV PATH="/root/.cargo/bin:${PATH}"
RUN cargo install cargo-fuzz

ADD . /repo
WORKDIR /repo/fuzz

RUN cargo fuzz build fuzz_reader && \
    mv target/x86_64-unknown-linux-gnu/release/fuzz_reader /fuzz_reader

RUN RUSTFLAGS="--cfg fuzzing -Clink-dead-code -Cdebug-assertions -C codegen-units=1" \
    cargo build --release && \
    mv target/release/fuzz_reader /fuzz_reader_no_inst

FROM ubuntu:22.04
COPY --from=builder /fuzz_reader /fuzz_reader_no_inst /
