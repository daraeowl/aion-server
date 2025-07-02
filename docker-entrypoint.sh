#!/bin/bash
set -e

# Wait-for-it function for service dependencies
db_wait() {
  local host="$1"
  local port="$2"
  echo "Waiting for $host:$port..."
  for i in {1..30}; do
    if nc -z "$host" "$port"; then
      echo "$host:$port is available!"
      return 0
    fi
    sleep 2
done
  echo "Timeout waiting for $host:$port"
  exit 1
}

# Set server directory based on SERVER_TYPE
case "$SERVER_TYPE" in
  login-server)
    SERVER_DIR="/opt/aion/login-server/login-server"
    DB_PORT=3306
    DB_NAME_VAR="AION_LS_DB"
    ;;
  game-server)
    SERVER_DIR="/opt/aion/game-server/game-server"
    DB_PORT=3306
    DB_NAME_VAR="AION_GS_DB"
    ;;
  chat-server)
    SERVER_DIR="/opt/aion/chat-server/chat-server"
    DB_PORT=3306
    DB_NAME_VAR="AION_CS_DB"
    ;;
  *)
    echo "Unknown SERVER_TYPE: $SERVER_TYPE"
    exit 1
    ;;
esac

# Wait for DB to be ready
db_wait "$DB_HOST" "$DB_PORT"

# For game-server, wait for login-server and chat-server
if [ "$SERVER_TYPE" = "game-server" ]; then
  db_wait "$LOGIN_SERVER_HOST" 9014
  db_wait "$CHAT_SERVER_HOST" 9021
fi

# Templating configuration files
CONFIG_DIR="$SERVER_DIR/config/network"
for f in "$CONFIG_DIR"/*.properties; do
  if [ -f "$f" ]; then
    echo "Templating $f"
    envsubst < "$f" > "$f.tmp" && mv "$f.tmp" "$f"
  fi
done

cd "$SERVER_DIR"

echo "==== DB CONFIG ENV ===="
echo "DB_HOST: $DB_HOST"
echo "DB_NAME: $DB_NAME"
echo "DB_USER: $DB_USER"
echo "DB_PASSWORD: $DB_PASSWORD"
echo "========================="

# Start the server
exec ./start.sh 