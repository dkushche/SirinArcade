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
                       gettext-base               \
                       nano                       \
    && apt-get clean

RUN ln -sf /sirin_arcade/sdk/cmake_build/sysroot/usr/lib/libSirinarcadeSDK.so /usr/lib/libSirinarcadeSDK.so
RUN if ! id 1000 >/dev/null 2>&1; then adduser --uid 1000 --home /home/ubuntu ubuntu; fi

ENV PATH=/sirin_arcade/sdk/cmake_build/sysroot/bin:$PATH

VOLUME /sirin_arcade

ARG SIRIN_AUDIO_CARD
ARG SIRIN_AUDIO_SUBDEVICE

RUN test -n "$SIRIN_AUDIO_CARD" # No Audio Card set
RUN test -n "$SIRIN_AUDIO_SUBDEVICE" # No Audio Subdevice set

ENV SIRIN_AUDIO_CARD=${SIRIN_AUDIO_CARD}
ENV SIRIN_AUDIO_SUBDEVICE=${SIRIN_AUDIO_SUBDEVICE}

COPY sirin_arcade/sdk/configs/.asoundrc.tmpl /root/.asoundrc.tmpl

RUN envsubst < /root/.asoundrc.tmpl > /root/.asoundrc
