FROM node:20-slim

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash claude

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY tsconfig.json ./
COPY src/ ./src/

RUN npm run build && chown -R claude:claude /app

USER claude

# docker compose volumes:
#
#   volumes:
#     - ~/.claude:/home/claude/.claude             # Claude credentials (from `claude login`)
#     - ./.env:/app/.env                           # Environment variables
#     - ./mcp-servers.json:/app/mcp-servers.json   # MCP server config (optional)
#     - /path/to/code:/code                        # Code directories Claude will work on
#                                                  # (set BASE_DIRECTORY=/code/ or DEFAULT_WORKING_DIRECTORY=/code/myproject)

CMD ["node", "dist/index.js"]
