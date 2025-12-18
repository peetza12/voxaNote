#!/bin/bash
set -e

# Find docker
DOCKER_CMD=""
if command -v docker &> /dev/null; then
    DOCKER_CMD="docker"
elif [ -f "/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
    DOCKER_CMD="/Applications/Docker.app/Contents/Resources/bin/docker"
else
    echo "❌ Docker not found"
    exit 1
fi

echo "📦 Creating MinIO bucket..."

# Get MinIO container
MINIO_CONTAINER=$($DOCKER_CMD ps --format "{{.Names}}" | grep -i minio | head -1)
if [ -z "$MINIO_CONTAINER" ]; then
    echo "❌ MinIO container not found"
    exit 1
fi

# Try to create bucket using MinIO client if available
if $DOCKER_CMD exec $MINIO_CONTAINER sh -c "command -v mc" &> /dev/null; then
    echo "Using MinIO client..."
    $DOCKER_CMD exec $MINIO_CONTAINER mc alias set local http://localhost:9000 minioadmin minioadmin
    $DOCKER_CMD exec $MINIO_CONTAINER mc mb local/voxa-note-audio --ignore-existing
    echo "✅ Bucket 'voxa-note-audio' created!"
else
    # Fallback: create bucket directory directly
    echo "Creating bucket directory..."
    $DOCKER_CMD exec $MINIO_CONTAINER sh -c "mkdir -p /data/voxa-note-audio && chmod 777 /data/voxa-note-audio"
    echo "✅ Bucket directory created!"
    echo "⚠️  You may still need to create it via MinIO console at http://localhost:9001"
fi

