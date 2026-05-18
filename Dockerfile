# BUILD THE SERVER IMAGE
ARG DOTNET_VERSION
FROM --platform=linux/amd64 mcr.microsoft.com/dotnet/runtime:${DOTNET_VERSION}

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    jq \
    curl \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

LABEL maintainer="support@indifferentbroccoli.com" \
      name="indifferentbroccoli/vintage-story-server-docker" \
      github="https://github.com/indifferentbroccoli/vintage-story-server-docker" \
      dockerhub="https://hub.docker.com/r/indifferentbroccoli/vintage-story-server-docker"

ENV HOME=/home/vintagestory \
    PUID=1000 \
    PGID=1000 \
    DEFAULT_PORT=42420 \
    SERVER_NAME="Indifferent Broccoli Vintage Story Server" \
    SERVER_PASSWORD="" \
    UPDATE_ON_START=true \
    VS_VERSION=latest \
    VS_BRANCH=stable \
    MAX_CLIENTS=16

RUN if getent passwd 1000 > /dev/null 2>&1; then \
        userdel "$(getent passwd 1000 | cut -d: -f1)"; \
    fi && \
    useradd -m -d /home/vintagestory -u 1000 vintagestory

COPY ./scripts /home/vintagestory/scripts/
COPY branding /branding

RUN mkdir -p /home/vintagestory/server-files && \
    chmod +x /home/vintagestory/scripts/*.sh

WORKDIR /home/vintagestory

HEALTHCHECK --start-period=5m \
            CMD pgrep -f "VintagestoryServer.dll" > /dev/null || exit 1

ENTRYPOINT ["/home/vintagestory/scripts/init.sh"]
