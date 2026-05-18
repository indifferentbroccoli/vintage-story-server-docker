#!/bin/bash
source "/home/vintagestory/scripts/functions.sh"

SERVER_FILES="/home/vintagestory/server-files"
DATA_PATH="${SERVER_FILES}/data"

cd "${SERVER_FILES}" || exit

LogAction "Starting Vintage Story Dedicated Server"

DEFAULT_PORT="${DEFAULT_PORT:-42420}"
MAX_PLAYERS="${MAX_PLAYERS:-16}"
SERVER_NAME="${SERVER_NAME:-Indifferent Broccoli Vintage Story Server}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"

mkdir -p "${DATA_PATH}"

SERVER_EXEC="${SERVER_FILES}/VintagestoryServer.dll"

if [ ! -f "${SERVER_EXEC}" ]; then
  LogError "Could not find server executable at: ${SERVER_EXEC}"
  exit 1
fi

CONFIG_FILE="${DATA_PATH}/serverconfig.json"

# If no config exists, let the server generate its own defaults, then kill it
if [ ! -f "${CONFIG_FILE}" ]; then
  LogInfo "No serverconfig.json found, generating defaults..."
  dotnet "${SERVER_EXEC}" --dataPath "${DATA_PATH}" > /dev/null 2>&1 &
  GEN_PID=$!
  WAITED=0
  while [ ! -f "${CONFIG_FILE}" ] && [ "${WAITED}" -lt 30 ]; do
    sleep 1
    WAITED=$((WAITED + 1))
  done
  kill "${GEN_PID}" 2>/dev/null
  wait "${GEN_PID}" 2>/dev/null
  if [ ! -f "${CONFIG_FILE}" ]; then
    LogError "Server failed to generate a default serverconfig.json"
    exit 1
  fi
  LogInfo "Default serverconfig.json generated"
fi

jq \
  --argjson port "${DEFAULT_PORT}" \
  --argjson maxClients "${MAX_PLAYERS}" \
  --arg serverName "${SERVER_NAME}" \
  --arg password "${SERVER_PASSWORD}" \
  '.Port = $port | .MaxClients = $maxClients | .ServerName = $serverName | .Password = $password' \
  "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

exec dotnet "${SERVER_EXEC}" --dataPath "${DATA_PATH}"
