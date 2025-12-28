#!/bin/bash
set -e

NETWORK_NAME="iot-shared-network"
COMPOSE_FILE="docker-compose.iot.yml"
BACKEND_HEALTH="http://localhost:3000/healthz"


command -v docker >/dev/null || { echo "Docker не встановлено"; exit 1; }
command -v docker-compose >/dev/null || { echo "Docker Compose не встановлено"; exit 1; }

echo " IoT параметри (Enter = default)"

read -p " Email [user@example.com]: " IOT_USER
IOT_USER=${IOT_USER:-user@example.com}

read -s -p " Password [string]: " IOT_PASS
echo
IOT_PASS=${IOT_PASS:-string}

read -p " Station ID [98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b]: " STATION_ID
STATION_ID=${STATION_ID:-98f6a2b1-5c3d-4e8f-9a1b-7c6d5e4f3a2b}

export IOT_USER
export IOT_PASS
export STATION_ID


if ! docker network ls --format '{{.Name}}' | grep -q "^${NETWORK_NAME}$"; then
    echo " Створюємо мережу $NETWORK_NAME..."
    docker network create $NETWORK_NAME
else
    echo " Мережа $NETWORK_NAME вже існує"
fi

echo " Очікуємо Backend..."
until curl -s $BACKEND_HEALTH >/dev/null 2>&1; do
    printf "."
    sleep 2
done
echo -e "\n Backend доступний"


echo " Запускаємо IoT + MQTT + Bridge..."
docker-compose -f $COMPOSE_FILE up -d

echo " Контейнери в мережі $NETWORK_NAME:"
docker ps --filter "network=$NETWORK_NAME"
