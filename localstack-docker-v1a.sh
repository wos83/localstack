#!/usr/bin/env bash

set -e

CONTAINER_NAME="localstack-server"
IMAGE="localstack/localstack:latest"
PORT_EDGE=4566
VOLUME_DIR="$HOME/.localstack"

echo "========================================"
echo "LocalStack Docker Runner - macOS Intel"
echo "========================================"
echo ""

# Detectar IPs da máquina
echo "Detectando IPs da máquina..."

HOSTNAME=$(hostname)
IPS=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}')

echo ""
echo "Hostname: $HOSTNAME"
echo "IPs disponíveis:"
echo "$IPS"
echo ""

# Criar diretório persistente
mkdir -p "$VOLUME_DIR"

# Remover container antigo de forma exata se existir
if [ "$(docker ps -aq -f name=^/${CONTAINER_NAME}$)" ]; then
    echo "Removendo container antigo..."
    docker rm -f "$CONTAINER_NAME"
fi

echo ""
echo "Iniciando LocalStack..."
echo ""

docker run -d \
    --name "$CONTAINER_NAME" \
    --restart unless-stopped \
    -p 0.0.0.0:${PORT_EDGE}:4566 \
    -e DEBUG=1 \
    -e LOCALSTACK_HOST=0.0.0.0 \
    -e GATEWAY_LISTEN=0.0.0.0:4566 \
    -v "$VOLUME_DIR:/var/lib/localstack" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    "$IMAGE"

echo ""
echo "========================================"
echo "LocalStack iniciado com sucesso!"
echo "========================================"
echo ""

for ip in $IPS; do
    echo "Acesso via rede:"
    echo "http://$ip:$PORT_EDGE"
done

echo ""
echo "Acesso local:"
echo "http://localhost:$PORT_EDGE"
echo ""

echo "Ver logs:"
echo "docker logs -f $CONTAINER_NAME"

echo ""
echo "Parar:"
echo "docker stop $CONTAINER_NAME"