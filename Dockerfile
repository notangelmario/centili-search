FROM python:3.8-slim as builder

RUN apt-get update && apt-get install -y \
    build-essential \
    libxml2-dev \
    libxslt-dev \
    libssl-dev \
    libffi-dev

COPY requirements.txt .

RUN pip install --prefix /install --no-warn-script-location --no-cache-dir -r requirements.txt

FROM python:3.8-slim

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    tor \
    && rm -rf /var/lib/apt/lists/*

ARG config_dir=/config
RUN mkdir -p $config_dir
VOLUME $config_dir
ENV CONFIG_VOLUME=$config_dir

ARG use_https=1

ARG username=''
ENV CENTILI_USER=$username
ARG password=''
ENV CENTILI_PASS=$password

ARG proxyuser=''
ENV CENTILI_PROXY_USER=$proxyuser
ARG proxypass=''
ENV CENTILI_PROXY_PASS=$proxypass
ARG proxytype=''
ENV CENTILI_PROXY_TYPE=$proxytype
ARG proxyloc=''
ENV CENTILI_PROXY_LOC=$proxyloc

ENV HTTPS_ONLY=$use_https

ARG centili_port=5000
ENV EXPOSE_PORT=$centili_port

ARG twitter_alt='nitter.net'
ENV CENTILI_ALT_TW=$twitter_alt
ARG youtube_alt='invidious.snopyta.org'
ENV CENTILI_ALT_YT=$youtube_alt
ARG instagram_alt='bibliogram.art/u'
ENV CENTILI_ALT_YT=$instagram_alt
ARG reddit_alt='libredd.it'
ENV CENTILI_ALT_RD=$reddit_alt

WORKDIR /CENTILI

COPY --from=builder /install /usr/local
COPY config/tor/torrc /etc/tor/torrc
COPY config/tor/start-tor.sh config/tor/start-tor.sh
COPY app/ app/
COPY run .

EXPOSE $EXPOSE_PORT

CMD config/tor/start-tor.sh & ./run
