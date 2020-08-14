# Dockerfile for latest factorio headless server
FROM python:3.8-buster as builder

ENV VERSION 1.0.0
ENV RCON_PASSWD defaultrconpassword

RUN mkdir -p /app/data/

COPY requirements.txt /app/

COPY sample_data_directory/ /app/data

WORKDIR /app

# Prepare factorio
RUN apt-get update && apt-get install wget \
    && wget https://www.factorio.com/get-download/${VERSION}/headless/linux64 -O tmp.tar \
    && tar xvf tmp.tar \
    && rm tmp.tar \
    && ln -s /app/data/mods /app/factorio/mods

FROM python:3.8-slim-buster as base

COPY --from=builder /app/ /app/

WORKDIR /app

# setup
RUN pip install -r requirements.txt \
    && mkdir -p ~/.config/fac/ \
    && echo ' \
    [paths] \
    data-path = /app/factorio/data \
    write-path = /app/factorio \
    ' > ~/.config/fac/config.ini

EXPOSE 34197/udp 27015

CMD ["/app/factorio/bin/x64/factorio", "--start-server", "/app/data/save.zip", "--server-settings", "/app/data/server-settings.json", "--rcon-port", "27015", "--rcon-password", "${RCON_PASSWD}", "--mod-directory", "/app/data/mods"]
