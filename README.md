<!-- markdownlint-disable-next-line -->
![marketing_assets_banner](https://github.com/user-attachments/assets/b8b4ae5c-06bb-46a7-8d94-903a04595036)
[![GitHub License](https://img.shields.io/github/license/indifferentbroccoli/vintage-story-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/vintage-story-server-docker/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/indifferentbroccoli/vintage-story-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/vintage-story-server-docker/releases)
[![GitHub Repo stars](https://img.shields.io/github/stars/indifferentbroccoli/vintage-story-server-docker?style=for-the-badge&color=6aa84f)](https://github.com/indifferentbroccoli/vintage-story-server-docker)
[![Discord](https://img.shields.io/discord/798321161082896395?style=for-the-badge&label=Discord&labelColor=5865F2&color=6aa84f)](https://discord.gg/indifferentbroccoli)
[![Docker Pulls](https://img.shields.io/docker/pulls/indifferentbroccoli/vintage-story-server-docker?style=for-the-badge&color=6aa84f)](https://hub.docker.com/r/indifferentbroccoli/vintage-story-server-docker)

Game server hosting

Fast RAM, high-speed internet

Eat lag for breakfast

[Try our Vintage Story server hosting free for 2 days!](https://indifferentbroccoli.com/vintage-story-server-hosting)

## Vintage Story Dedicated Server Docker

A Docker container for running a Vintage Story dedicated server.

## Image Tags

| Tag | .NET | Vintage Story |
|-----|------|---------------|
| `latest`, `dotnet10` | 10.0 | 1.22.x+ |
| `dotnet8` | 8.0 | 1.21.x |
| `dotnet7` | 7.0 | 1.x – 1.20.x |

## Server Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 2 cores | 4+ cores |
| RAM | 2 GB | 4+ GB |
| Storage | 2 GB | 5+ GB |

## How to use

Copy the `.env.example` file to a new file called `.env`. Then use either `docker compose` or `docker run`.

### Docker Compose

```yaml
services:
  vintagestory:
    image: indifferentbroccoli/vintage-story-server-docker
    restart: unless-stopped
    container_name: vintagestory
    stop_grace_period: 30s
    ports:
      - 42420:42420/udp
      - 42420:42420/tcp
    env_file:
      - .env
    volumes:
      - ./server-files:/home/vintagestory/server-files
      - ./server-data:/home/vintagestory/server-data
```

Then run:

```bash
docker compose up -d
```

### Docker Run

```bash
docker run -d \
    --restart unless-stopped \
    --name vintagestory \
    --stop-timeout 30 \
    -p 42420:42420/udp \
    -p 42420:42420/tcp \
    --env-file .env \
    -v ./server-files:/home/vintagestory/server-files \
    -v ./server-data:/home/vintagestory/server-data \
    indifferentbroccoli/vintage-story-server-docker
```

## Environment Variables

You can use the following values to change the settings of the server on boot.

| Variable | Default | Info |
|---|---|---|
| PUID | 1000 | User ID for file permissions |
| PGID | 1000 | Group ID for file permissions |
| SERVER_NAME | Indifferent Broccoli Vintage Story Server | Name of the server |
| SERVER_PASSWORD | | Password required to join the server |
| DEFAULT_PORT | 42420 | The port the server listens on (UDP + TCP) |
| MAX_PLAYERS | 16 | Maximum number of players |
| UPDATE_ON_START | true | If set to false, skips downloading server files on startup |
| VS_VERSION | 1.20.12 | Vintage Story server version to download |
| VS_BRANCH | stable | Release branch (`stable` or `unstable`) |

> [!NOTE]
> All other server settings (game rules, world size, roles, etc.) are configured directly in `serverconfig.json` inside the `server-data` volume.

## Port Forwarding

Forward port `42420` UDP and TCP on your router to the host machine.

## Server Configuration

> [!NOTE]
> Changes to `serverconfig.json` require a server restart to take effect.

## Support

For issues and questions:

- GitHub Issues: [Report an issue](https://github.com/indifferentbroccoli/vintage-story-server-docker/issues)
- Game Server Hosting: [indifferentbroccoli.com](https://indifferentbroccoli.com)