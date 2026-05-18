#!/bin/bash
source "/home/vintagestory/scripts/functions.sh"

SERVER_FILES="/home/vintagestory/server-files"
DATA_PATH="${SERVER_FILES}/data"

cd "${SERVER_FILES}" || exit

LogAction "Starting Vintage Story Dedicated Server"

DEFAULT_PORT="${DEFAULT_PORT:-42420}"
MAX_CLIENTS="${MAX_CLIENTS:-16}"
SERVER_NAME="${SERVER_NAME:-Indifferent Broccoli Vintage Story Server}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"

mkdir -p "${DATA_PATH}"

CONFIG_FILE="${DATA_PATH}/serverconfig.json"

# Create a base config if one does not exist
if [ ! -f "${CONFIG_FILE}" ]; then
  LogInfo "Creating serverconfig.json"
  echo '{}' > "${CONFIG_FILE}"
fi

jq \
  --argjson port "${DEFAULT_PORT}" \
  --argjson maxClients "${MAX_CLIENTS}" \
  --arg serverName "${SERVER_NAME}" \
  --arg password "${SERVER_PASSWORD}" \
  '.Port = $port | .MaxClients = $maxClients | .ServerName = $serverName | .Password = $password' \
  "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

SERVER_EXEC="${SERVER_FILES}/VintagestoryServer.dll"

if [ ! -f "${SERVER_EXEC}" ]; then
  LogError "Could not find server executable at: ${SERVER_EXEC}"
  exit 1
fi

exec dotnet "${SERVER_EXEC}" --dataPath "${DATA_PATH}"
