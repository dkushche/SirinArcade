FROM ubuntu:24.04

RUN apt-get update &&                             \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC     \
    apt-get install -y gosu                       \
                       build-essential            \
                       libncurses5-dev            \
                       cmake                      \
                       curl                       \
                       libasound2-dev             \
                       alsa-utils                 \
                       libsndfile1-dev            \
                       gettext-base               \
                       nano                       \
                       libcurl4-gnutls-dev        \
                       busybox                    \
    && apt-get clean

RUN if ! id 1000 >/dev/null 2>&1; then adduser --uid 1000 --home /home/ubuntu ubuntu; fi

RUN curl --proto '=https' --tlsv1.2 -o rustup-init.sh https://sh.rustup.rs
RUN gosu 1000 bash rustup-init.sh -y

ENV PATH=/home/ubuntu/.cargo/bin:$PATH

ENV SIRIN_ARCADES_SERVER_PORT=9876
ENV SIRIN_ARCADES_CLIENT_PORT=6789

ENV PATH=/sirin_arcades/sdk/cmake_build/sysroot/bin:$PATH

VOLUME /sirin_arcades

ARG SIRIN_AUDIO_CARD
ARG SIRIN_AUDIO_SUBDEVICE

RUN test -n "$SIRIN_AUDIO_CARD" # No Audio Card set
RUN test -n "$SIRIN_AUDIO_SUBDEVICE" # No Audio Subdevice set

ENV SIRIN_AUDIO_CARD=${SIRIN_AUDIO_CARD}
ENV SIRIN_AUDIO_SUBDEVICE=${SIRIN_AUDIO_SUBDEVICE}

COPY build_utils/rln /bin
COPY sirin_arcades/sdk/sound_player/resources/.asoundrc.tmpl /root/.asoundrc.tmpl

RUN envsubst < /root/.asoundrc.tmpl > /root/.asoundrc
