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

# shellcheck disable=SC2317
term_handler() {
  if ! shutdown_server; then
    kill -SIGTERM "$(pgrep -f "VintagestoryServer.dll")"
  fi
  tail --pid="$killpid" -f 2>/dev/null
}

trap 'term_handler' SIGTERM

export DEFAULT_PORT
export MAX_CLIENTS
export SERVER_NAME
export SERVER_PASSWORD

su - vintagestory -c "cd /home/vintagestory/scripts && \
  DEFAULT_PORT='${DEFAULT_PORT}' \
  MAX_CLIENTS='${MAX_CLIENTS}' \
  SERVER_NAME='${SERVER_NAME}' \
  SERVER_PASSWORD='${SERVER_PASSWORD}' \
  ./start.sh" &

killpid="$!"
wait "$killpid"
