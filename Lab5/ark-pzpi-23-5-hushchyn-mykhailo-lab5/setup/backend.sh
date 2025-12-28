#!/bin/bash
set -e


DEFAULT_DB_USER="postgres"
DEFAULT_DB_PASS="postgres"
DEFAULT_DB_NAME="iot_db"
DEFAULT_DB_HOST="postgres"
DEFAULT_DB_PORT="5432"

NETWORK_NAME="iot-shared-network"
COMPOSE_FILE="docker-compose.backend.yml"

command -v docker >/dev/null || { echo " Docker не встановлено"; exit 1; }
command -v docker-compose >/dev/null || { echo " Docker Compose не встановлено"; exit 1; }

echo " Налаштування PostgreSQL (Enter = default)"

read -p "DB USER [$DEFAULT_DB_USER]: " DB_USER
DB_USER=${DB_USER:-$DEFAULT_DB_USER}

read -p "DB PASSWORD [$DEFAULT_DB_PASS]: " DB_PASS
DB_PASS=${DB_PASS:-$DEFAULT_DB_PASS}

read -p "DB NAME [$DEFAULT_DB_NAME]: " DB_NAME
DB_NAME=${DB_NAME:-$DEFAULT_DB_NAME}

DATABASE_URL="postgres://${DB_USER}:${DB_PASS}@${DEFAULT_DB_HOST}:${DEFAULT_DB_PORT}/${DB_NAME}"

export DATABASE_URL
export DB_USER
export DB_PASS
export DB_NAME

echo " DATABASE_URL = $DATABASE_URL"


if ! docker network ls --format '{{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
    echo " Створюємо мережу $NETWORK_NAME..."
    docker network create $NETWORK_NAME
else
    echo " Мережа $NETWORK_NAME вже існує"
fi


echo " Піднімаємо Backend + PostgreSQL..."
docker-compose -f $COMPOSE_FILE up -d

echo " Backend запущено"
docker ps --filter "network=$NETWORK_NAME"
