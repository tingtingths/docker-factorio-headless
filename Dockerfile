# Dockerfile for latest factorio headless server

ARG FACTORIO_VERSION=1.0.0
ARG FH_DOWNLOAD_URL=https://www.factorio.com/get-download/${FACTORIO_VERSION}/headless/linux64
# https://github.com/sparr/fac/pull/8
ARG FAC_REPO=https://github.com/lowne/fac
ARG FH_UID=1000

FROM python:slim AS base
ARG FH_UID
RUN useradd --comment "factorio" --create-home --home-dir /data --user-group --uid ${FH_UID} factorio

FROM base AS build
ARG FH_UID
ARG FH_DOWNLOAD_URL
ARG FAC_REPO

RUN apt-get -y update && apt-get install -y --no-install-recommends wget xz-utils git

############### Download factorio
WORKDIR /factorio
RUN wget ${FH_DOWNLOAD_URL} -O tmp.tar \
 && tar xvf tmp.tar --strip-components=1 \
 && rm tmp.tar

############### Download fac
RUN git clone --depth=1 ${FAC_REPO} fac


FROM base AS deploy
ARG FH_UID

COPY --from=build --chown=${FH_UID} /factorio /factorio
############## install fac (as root)
RUN pip3 install -e /factorio/fac

USER ${FH_UID}
RUN echo "use-system-read-write-data-directories=false"\\n"config-path=/data/config" > /factorio/config-path.cfg \
 && mkdir -p /data/config \
 && echo "[path]"\\n"read-data=/factorio/data"\\n"write-data=/data" > /data/config/config.ini \
 && chmod a+w /data/config/config.ini

############## install tools
COPY --chown=${FH_UID} listmods.py /usr/local/bin/listmods
COPY --chown=${FH_UID} start.sh /usr/local/bin/start-server

############## setup datadir (redundant if mounting /data)
COPY --chown=${FH_UID} sample_data_directory/ /data
RUN mkdir -p /data/.config/fac \
 && echo "[paths]"\\n"data-path=/factorio/data"\\n"write-path=/data" > /data/.config/fac/config.ini

ENV RCON_PASSWD=
ENV SKIP_AUTOMODS=
ENV SAVEGAME="save"

CMD start-server ${SAVEGAME}

EXPOSE 34197/udp 27015

