#!/bin/bash
# shellcheck source=scripts/functions.sh
source "/home/vintagestory/scripts/functions.sh"

LogAction "Set file permissions"

if [ -z "${PUID}" ] || [ -z "${PGID}" ]; then
  LogError "PUID and PGID not set. Please set these in the environment variables."
  exit 1
else
  usermod -o -u "${PUID}" vintagestory
  groupmod -o -g "${PGID}" vintagestory
fi

chown -R vintagestory:vintagestory /home/vintagestory/server-files \
  /home/vintagestory/

cat /branding

if [ "${UPDATE_ON_START:-true}" = "true" ]; then
  install
else
  LogWarn "UPDATE_ON_START is set to false, skipping server download"
fi

mkfifo /tmp/vs_input
exec gosu vintagestory /home/vintagestory/scripts/start.sh <>/tmp/vs_input
