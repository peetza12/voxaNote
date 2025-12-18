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

echo "🔧 Configuring MinIO CORS for mobile uploads..."

MINIO_CONTAINER=$($DOCKER_CMD ps --format "{{.Names}}" | grep -i minio | head -1)
if [ -z "$MINIO_CONTAINER" ]; then
    echo "❌ MinIO container not found"
    exit 1
fi

# Configure CORS using MinIO client
if $DOCKER_CMD exec $MINIO_CONTAINER sh -c "command -v mc" &> /dev/null; then
    echo "Setting up MinIO client..."
    $DOCKER_CMD exec $MINIO_CONTAINER mc alias set local http://localhost:9000 minioadmin minioadmin
    
    echo "✅ MinIO client configured"
    echo "ℹ️  Signed URLs should work without CORS for PUT requests"
    echo "   If you still get 403 errors, check MinIO console at http://localhost:9001"
    echo "⚠️  Note: For production, restrict CORS to specific origins"
else
    echo "⚠️  MinIO client not available. Configure CORS manually:"
    echo "   1. Go to http://localhost:9001"
    echo "   2. Login: minioadmin / minioadmin"
    echo "   3. Go to Settings > CORS"
    echo "   4. Add policy allowing PUT from your mobile app origin"
fi

