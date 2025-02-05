FROM ubuntu:24.04

RUN apt-get update &&                             \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC     \
    apt-get install -y gosu                       \
                       build-essential            \
                       libncurses5-dev            \
                       cmake                      \
                       curl                       \
    && apt-get clean

RUN if ! id 1000 >/dev/null 2>&1; then adduser --uid 1000 --home /home/ubuntu ubuntu; fi

USER ubuntu
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/home/ubuntu/.cargo/bin:${PATH}"

ENV SIRIN_ARCADE_SERVER_PORT=9876
ENV SIRIN_ARCADE_CLIENT_PORT=6789

USER root

VOLUME /workdir
