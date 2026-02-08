FROM node:22-slim AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src/ ./src/

RUN npm run build

FROM node:22-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash claude

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev

COPY --from=build /app/dist ./dist

RUN chown -R claude:claude /app

USER claude

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD node -e "process.exit(0)"

# docker compose example:
#
#   environment:
#     - SLACK_BOT_TOKEN=xoxb-...
#     - SLACK_APP_TOKEN=xapp-...
#     - SLACK_SIGNING_SECRET=...
#     - ANTHROPIC_API_KEY=...              # or omit if using Claude subscription
#     - BASE_DIRECTORY=/code/
#   # or use env_file:
#   #   env_file: .env
#
#   volumes:
#     - ~/.claude:/home/claude/.claude             # Claude credentials (from `claude login`, needed for subscription)
#     - ./mcp-servers.json:/app/mcp-servers.json   # MCP server config (optional)
#     - /path/to/code:/code                        # Code directories Claude will work on

CMD ["node", "dist/index.js"]
