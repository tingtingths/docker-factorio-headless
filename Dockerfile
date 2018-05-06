# Dockerfile for latest factorio headless server
FROM ubuntu:17.10

ENV RCON_PASSWD defaultrconpassword

RUN mkdir -p /app \
    /app/data

WORKDIR /app
RUN apt-get update && apt-get -y install wget tar xz-utils

# Prepare factorio headless binary
RUN wget https://www.factorio.com/get-download/stable/headless/linux64 -O tmp.tar \
    && tar xvf tmp.tar && rm tmp.tar

EXPOSE 34197/udp 27015

CMD ["/app/factorio/bin/x64/factorio", "--start-server", "/app/data/save.zip", "--server-settings", "/app/data/server-settings.json", "--rcon-port", "27015", "--rcon-password", "${RCON_PASSWD}", "--mod-directory", "/app/data/mods"]
