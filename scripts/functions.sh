#!/bin/bash

#================
# Log Definitions
#================
export LINE='\n'
export RESET='\033[0m'
export WhiteText='\033[0;37m'         # White

# Bold
export RedBoldText='\033[1;31m'       # Red
export GreenBoldText='\033[1;32m'     # Green
export YellowBoldText='\033[1;33m'    # Yellow
export CyanBoldText='\033[1;36m'      # Cyan
#================
# End Log Definitions
#================

LogInfo() {
  Log "$1" "$WhiteText"
}
LogWarn() {
  Log "$1" "$YellowBoldText"
}
LogError() {
  Log "$1" "$RedBoldText"
}
LogSuccess() {
  Log "$1" "$GreenBoldText"
}
LogAction() {
  Log "$1" "$CyanBoldText" "====" "===="
}
Log() {
  local message="$1"
  local color="$2"
  local prefix="$3"
  local suffix="$4"
  printf "$color%s$RESET$LINE" "$prefix$message$suffix"
}

stratum_enabled() {
  [ "${STRATUM_ENABLED:-false}" = "true" ]
}

resolve_vs_version() {
  local version="${VS_VERSION:-latest}"
  local branch="${VS_BRANCH:-stable}"

  if [ "${version}" != "latest" ]; then
    echo "${version}"
    return 0
  fi

  LogInfo "Resolving latest ${branch} version..." >&2
  version=$(curl -sf "https://api.vintagestory.at/${branch}.json" \
    | jq -r 'to_entries[] | select(.value.linuxserver.latest == 1) | .key')

  if [ -z "${version}" ]; then
    LogError "Failed to resolve latest version from https://api.vintagestory.at/${branch}.json" >&2
    return 1
  fi

  LogInfo "Resolved latest version: ${version}" >&2
  echo "${version}"
}

install() {
  local version
  local branch="${VS_BRANCH:-stable}"
  local server_files="/home/vintagestory/server-files"

  version=$(resolve_vs_version) || exit 1

  LogAction "Starting Vintage Story server install"
  LogInfo "Version: ${version} (${branch})"

  # Skip if already installed at this version
  if [ -f "${server_files}/.vs_version" ] && [ "$(cat "${server_files}/.vs_version")" = "${version}" ]; then
    LogInfo "Vintage Story server v${version} already installed, skipping download"
    return
  fi

  LogInfo "Downloading Vintage Story server v${version}..."
  wget -q --tries=3 --waitretry=5 \
    "https://cdn.vintagestory.at/gamefiles/${branch}/vs_server_linux-x64_${version}.tar.gz" \
    -O /tmp/vs_server.tar.gz

  if [ $? -ne 0 ]; then
    LogError "Failed to download Vintage Story server v${version} from branch '${branch}'"
    exit 1
  fi

  tar -xzf /tmp/vs_server.tar.gz -C "${server_files}"
  rm /tmp/vs_server.tar.gz
  echo "${version}" > "${server_files}/.vs_version"
  LogSuccess "Vintage Story server v${version} installed"
}

install_stratum() {
  local vs_version tag
  local server_files="/home/vintagestory/server-files"

  vs_version=$(resolve_vs_version) || exit 1

  # Releases come back newest first, tagged v<vs-version>-stratum.<rev>
  tag=$(curl -sf "https://api.github.com/repos/StratumServer/Stratum/releases?per_page=100" \
    | jq -r '.[] | select(.prerelease == false) | .tag_name' \
    | grep -m1 "^v${vs_version}-stratum\.")

  if [ -z "${tag}" ]; then
    LogError "No stable Stratum release found for Vintage Story ${vs_version}"
    exit 1
  fi

  LogAction "Starting Stratum server install"
  LogInfo "Release: ${tag}"

  if [ -f "${server_files}/.vs_version" ] && [ "$(cat "${server_files}/.vs_version")" = "${tag}" ]; then
    LogInfo "Stratum ${tag} already installed, skipping download"
    return
  fi

  LogInfo "Downloading Stratum ${tag}..."
  wget -q --tries=3 --waitretry=5 \
    "https://github.com/StratumServer/Stratum/releases/download/${tag}/stratum-${tag#v}-linux-x64.zip" \
    -O /tmp/stratum.zip

  if [ $? -ne 0 ]; then
    LogError "Failed to download Stratum ${tag}"
    exit 1
  fi

  unzip -oq /tmp/stratum.zip -d "${server_files}"
  rm /tmp/stratum.zip
  echo "${tag}" > "${server_files}/.vs_version"

  chmod +x "${server_files}/StratumServer"
  chown -R vintagestory:vintagestory "${server_files}"

  LogSuccess "Stratum ${tag} installed"
}

# Attempt to shutdown the server gracefully
# Returns 0 if successful
# Returns 1 if not able to shutdown
shutdown_server() {
  local return_val=0
  LogAction "Attempting graceful server shutdown"

  local pid
  pid=$(pgrep -f "VintagestoryServer.dll|StratumServer")

  if [ -n "$pid" ]; then
    kill -SIGTERM "$pid"

    local count=0
    while [ $count -lt 30 ] && kill -0 "$pid" 2>/dev/null; do
      sleep 1
      count=$((count + 1))
    done

    if kill -0 "$pid" 2>/dev/null; then
      LogWarn "Server did not shutdown gracefully, forcing shutdown"
      return_val=1
    else
      LogSuccess "Server shutdown gracefully"
    fi
  else
    LogWarn "Server process not found"
    return_val=1
  fi

  return "$return_val"
}
