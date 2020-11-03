#!/bin/bash

set -eu

if [[ -n "${1}" ]]; then
  SAVEGAME="${1}"
fi
if [[ -z "${SAVEGAME}" ]]; then
  echo "usage: start-server <savegame_name>"
  exit 1
fi
SAVEFILE="/data/saves/${SAVEGAME}.zip"
if [[ ! -f "${SAVEFILE}" ]]; then
  echo "file ${SAVEFILE} not found, aborting."
  exit 1
fi

fac search ha #build index

ENABLED_MODS=$(fac list|tail -n +2|grep -v "(disabled)"|tr -s ' '|rev|cut -d' ' -f2-|rev|cut -c2-|sort)
echo "Mods currently enabled: "
echo ${ENABLED_MODS}

if [[ -f "/data/mods.txt" ]]; then
  REQUIRED_MODS=$(cat "/data/mods.txt"|sort)
  echo "Mods required in /data/mods.txt:"
  echo ${REQUIRED_MODS}
else
  REQUIRED_MODS=$(listmods ${SAVEFILE}|tail -n +2|grep -v '^base'|sort)
  echo "Mods required in savegame ${SAVEFILE}:"
  echo ${REQUIRED_MODS}
fi

if [[ -z "${SKIP_AUTOMODS}" ]]; then
  if [[ ${ENABLED_MODS} != ${REQUIRED_MODS} ]]; then
    IFS=$'\n'
    for mod in ${ENABLED_MODS}; do
      echo "Disable mod ${mod}"
      fac disable "${mod}"
    done
    IFS=$'\n'
    for mod in ${REQUIRED_MODS}; do
      echo "Enable mod ${mod}"
      fac install "${mod}"
      fac enable "${mod}"
    done
  fi
fi

RCON="" #only enable rcon if we have a password
if [[ -n ${RCON_PASSWD} ]]; then
  RCON="--rcon-port 27015 --rcon-password"
fi

exec /factorio/bin/x64/factorio --start-server "${SAVEFILE}" --server-settings "/data/server-settings.json" --mod-directory "/data/mods" --console-log "/data/console.log" ${RCON} "${RCON_PASSWD}"

