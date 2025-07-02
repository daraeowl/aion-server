# syntax=docker/dockerfile:1.4

# --- Build Stage ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build
COPY . .
RUN mvn clean package -DskipTests

# --- Runtime Stage ---
FROM eclipse-temurin:21-jdk AS runtime

# Install envsubst and unzip for configuration templating and extraction
RUN apt-get update && apt-get install -y --no-install-recommends gettext-base bash unzip netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Create directories for each server type
RUN mkdir -p /opt/aion/game-server /opt/aion/login-server /opt/aion/chat-server

# Copy built zip distributions from build stage
COPY --from=build /build/game-server/target/game-server.zip /opt/aion/game-server.zip
COPY --from=build /build/login-server/target/login-server.zip /opt/aion/login-server.zip
COPY --from=build /build/chat-server/target/chat-server.zip /opt/aion/chat-server.zip

# Unzip distributions to their respective directories
RUN unzip /opt/aion/game-server.zip -d /opt/aion/game-server && \
    unzip /opt/aion/login-server.zip -d /opt/aion/login-server && \
    unzip /opt/aion/chat-server.zip -d /opt/aion/chat-server && \
    rm /opt/aion/*.zip

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set permissions for start scripts
RUN chmod +x /opt/aion/game-server/game-server/start.sh /opt/aion/login-server/login-server/start.sh /opt/aion/chat-server/chat-server/start.sh

# Expose required ports
EXPOSE 2106 7777 9014 9021 10241

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"] 