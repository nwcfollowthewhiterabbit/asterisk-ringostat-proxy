ARG ASTERISK_VERSION=22.9.0
FROM debian:13-slim

ARG ASTERISK_VERSION

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        gettext-base \
        libcurl4-openssl-dev \
        libedit-dev \
        libjansson-dev \
        libncurses-dev \
        libnewt-dev \
        libspeex-dev \
        libspeexdsp-dev \
        libsrtp2-dev \
        libsqlite3-dev \
        libssl-dev \
        libxml2-dev \
        pkg-config \
        uuid-dev \
        wget \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --system --home /var/lib/asterisk --shell /usr/sbin/nologin asterisk \
    && mkdir -p /etc/asterisk /var/lib/asterisk /var/log/asterisk /var/spool/asterisk /var/run/asterisk \
    && chown -R asterisk:asterisk /etc/asterisk /var/lib/asterisk /var/log/asterisk /var/spool/asterisk /var/run/asterisk

WORKDIR /usr/src

RUN wget -O asterisk.tar.gz "https://downloads.asterisk.org/pub/telephony/asterisk/asterisk-${ASTERISK_VERSION}.tar.gz" \
    && tar -xzf asterisk.tar.gz \
    && cd "asterisk-${ASTERISK_VERSION}" \
    && ./configure --with-pjproject-bundled \
    && make -j"$(nproc)" \
    && make install \
    && make samples \
    && make config \
    && ldconfig \
    && cd /usr/src \
    && rm -rf "asterisk-${ASTERISK_VERSION}" asterisk.tar.gz

RUN rm -f /etc/asterisk/*.conf

EXPOSE 5060/udp 10000-20000/udp

