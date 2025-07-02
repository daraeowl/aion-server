# Aion Server Docker Deployment

This guide explains how to build and run the Aion server using Docker and Docker Compose.

## Prerequisites

- Docker (v20.10+ recommended)
- Docker Compose (v2.0+ recommended)
- At least 6GB RAM (8GB+ recommended for all services)
- 10GB+ free disk space

## Quick Start

1. **Clone the repository**
2. **Copy and adjust the `.env` file** (optional)
3. **Build the Docker image:**
   ```sh
   docker compose build
   ```
4. **Start all services:**
   ```sh
   docker compose up -d
   ```
5. **Check service status:**
   ```sh
   docker compose ps
   ```
6. **View logs:**
   ```sh
   docker compose logs -f
   ```

## Configuration

All configuration is managed via the `.env` file. You can override any variable before running Compose.

### Database
- `MYSQL_ROOT_PASSWORD`: Root password for MariaDB
- `DB_USER`, `DB_PASSWORD`: Credentials for Aion databases
- `AION_LS_DB`, `AION_GS_DB`, `AION_CS_DB`: Database names for each service

### Inter-Service
- `LOGIN_SERVER_HOST`, `CHAT_SERVER_HOST`: Hostnames for internal service communication

### Server Memory
- `GAME_SERVER_XMX`, `LOGIN_SERVER_XMX`, `CHAT_SERVER_XMX`: Java heap sizes (e.g., 4G)

### Timezone
- `TZ`: Timezone for all containers

## Service Management

- **Start all services:** `docker compose up -d`
- **Stop all services:** `docker compose down`
- **Restart a service:** `docker compose restart <service>`
- **Scale services:** Not typically needed (one of each server)
- **Backup DB:**
  ```sh
  docker exec aion-db mariadb-dump -u root -p$MYSQL_ROOT_PASSWORD --all-databases > backup.sql
  ```
- **Restore DB:**
  ```sh
  docker exec -i aion-db mariadb -u root -p$MYSQL_ROOT_PASSWORD < backup.sql
  ```

## Development Workflow

- **Rebuild after code changes:** `docker compose build --no-cache`
- **Access logs:** `docker compose logs -f <service>`
- **Connect to DB:** Use a client to connect to `localhost:3306` (user/password from `.env`)

## Production Considerations

- Adjust memory limits in `.env` as needed
- Use secure passwords in production
- Regularly backup the database
- Monitor container health and logs

## Troubleshooting

- **Database not ready:** Services will wait for DB health before starting
- **Port conflicts:** Ensure required ports (2106, 7777, 9014, 9021, 10241) are available
- **Configuration changes:** Edit `.env` and restart affected services

## References

- See the main `README.md` for game-specific setup and configuration
- Configuration templates are in each server's `config/network/` directory
- SQL initialization scripts are in each server's `sql/` directory 