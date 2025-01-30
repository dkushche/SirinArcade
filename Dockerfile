FROM ubuntu:24.04

RUN apt-get update &&                             \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC     \
    apt-get install -y gosu                       \
                       build-essential            \
                       libncurses5-dev            \
                       cmake                      \
                       libasound2-dev             \
                       alsa-utils                 \
                       libsndfile1-dev            \
    && apt-get clean

RUN if ! id 1000 >/dev/null 2>&1; then adduser --uid 1000 --home /home/ubuntu ubuntu; fi

VOLUME /workdir
