FROM ghcr.io/hauxir/brock_samson:d4dfec

WORKDIR /app

COPY package.json package-lock.json tsconfig.json ./
COPY src/ ./src/

RUN npm ci && npm run build && rm -rf src/ tsconfig.json node_modules && npm ci --omit=dev

RUN chown -R brock:brock /app

USER brock

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
#     - ~/.claude:/home/brock/.claude             # Claude credentials (from `claude login`, needed for subscription)
#     - ./mcp-servers.json:/app/mcp-servers.json   # MCP server config (optional)
#     - /path/to/code:/code                        # Code directories Claude will work on

ENTRYPOINT []
CMD ["node", "dist/index.js"]
