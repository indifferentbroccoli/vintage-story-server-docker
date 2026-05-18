#!/bin/bash
source "/home/vintagestory/scripts/functions.sh"

SERVER_FILES="/home/vintagestory/server-files"
DATA_PATH="/home/vintagestory/server-data"

cd "${SERVER_FILES}" || exit

LogAction "Starting Vintage Story Dedicated Server"

DEFAULT_PORT="${DEFAULT_PORT:-42420}"
MAX_PLAYERS="${MAX_PLAYERS:-16}"
SERVER_NAME="${SERVER_NAME:-Indifferent Broccoli Vintage Story Server}"
SERVER_PASSWORD="${SERVER_PASSWORD:-}"
SAVE_FILE="${SAVE_FILE:-${DATA_PATH}/Saves/default.vcdbs}"
MOD_PATH="${MOD_PATH:-${DATA_PATH}/Mods}"

mkdir -p "${DATA_PATH}"

SERVER_EXEC="${SERVER_FILES}/VintagestoryServer.dll"

if [ ! -f "${SERVER_EXEC}" ]; then
  LogError "Could not find server executable at: ${SERVER_EXEC}"
  exit 1
fi

CONFIG_FILE="${DATA_PATH}/serverconfig.json"

# If no config exists, copy the bundled example as a starting point
if [ ! -f "${CONFIG_FILE}" ]; then
  LogInfo "No serverconfig.json found, copying defaults..."
  cp "/home/vintagestory/scripts/example_serverconfig.json" "${CONFIG_FILE}"
  LogInfo "Default serverconfig.json copied"
fi

jq \
  --argjson port "${DEFAULT_PORT}" \
  --argjson maxClients "${MAX_PLAYERS}" \
  --arg serverName "${SERVER_NAME}" \
  --arg password "${SERVER_PASSWORD}" \
  --arg saveFile "${SAVE_FILE}" \
  --arg modPath "${MOD_PATH}" \
  '.WorldConfig.SaveFileLocation = $saveFile | .ModPaths = ["Mods", $modPath] | .Port = $port | .MaxClients = $maxClients | .ServerName = $serverName | .Password = $password' \
  "${CONFIG_FILE}" > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "${CONFIG_FILE}"

exec dotnet "${SERVER_EXEC}" --dataPath "${DATA_PATH}"
