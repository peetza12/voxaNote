#!/bin/bash
set -e

echo "🔧 Completing VoxaNote setup..."

# Find docker command
DOCKER_CMD=""
if command -v docker &> /dev/null; then
    DOCKER_CMD="docker"
elif [ -f "/Applications/Docker.app/Contents/Resources/bin/docker" ]; then
    DOCKER_CMD="/Applications/Docker.app/Contents/Resources/bin/docker"
else
    echo "❌ Docker not found. Please start Docker Desktop and try again."
    exit 1
fi

# Find docker-compose
COMPOSE_CMD=""
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif $DOCKER_CMD compose version &> /dev/null 2>&1; then
    COMPOSE_CMD="$DOCKER_CMD compose"
else
    echo "❌ docker-compose not found"
    exit 1
fi

cd "$(dirname "$0")"

# Check if containers are running
echo "📦 Checking containers..."
if ! $COMPOSE_CMD ps | grep -q "Up"; then
    echo "⚠️  Containers not running. Starting them..."
    $COMPOSE_CMD up -d
    echo "⏳ Waiting for services to be ready..."
    sleep 10
fi

# Get Postgres container name
POSTGRES_CONTAINER=$($DOCKER_CMD ps --format "{{.Names}}" | grep -i postgres | head -1)
if [ -z "$POSTGRES_CONTAINER" ]; then
    echo "❌ Postgres container not found. Is docker compose up -d running?"
    exit 1
fi

echo "✅ Found Postgres container: $POSTGRES_CONTAINER"

# Wait for Postgres to be ready
echo "⏳ Waiting for Postgres to be ready..."
for i in {1..30}; do
    if $DOCKER_CMD exec $POSTGRES_CONTAINER pg_isready -U voxa_user -d voxa_note &> /dev/null; then
        break
    fi
    sleep 1
done

# Run migrations
echo "📊 Running database migrations..."
$DOCKER_CMD exec -i $POSTGRES_CONTAINER psql -U voxa_user -d voxa_note < server/migrations/001_init.sql

echo "✅ Database migrations complete!"

# Check MinIO
MINIO_CONTAINER=$($DOCKER_CMD ps --format "{{.Names}}" | grep -i minio | head -1)
if [ -n "$MINIO_CONTAINER" ]; then
    echo "✅ MinIO container: $MINIO_CONTAINER"
    echo "📦 MinIO Console: http://localhost:9001"
    echo "   Login: minioadmin / minioadmin"
    echo "   Create bucket: voxa-note-audio"
    echo ""
    echo "⚠️  Please create the 'voxa-note-audio' bucket in MinIO:"
    echo "   1. Open http://localhost:9001"
    echo "   2. Login with minioadmin / minioadmin"
    echo "   3. Click 'Create Bucket'"
    echo "   4. Name it: voxa-note-audio"
fi

# Check .env file
if [ ! -f "server/.env" ]; then
    echo "📝 Creating .env file..."
    cat > server/.env << 'EOF'
PORT=4000
NODE_ENV=development

POSTGRES_URL=postgres://voxa_user:voxa_pass@localhost:5432/voxa_note

# Replace with your actual OpenAI API key
OPENAI_API_KEY=your-openai-api-key-here

S3_ENDPOINT=http://localhost:9000
S3_REGION=us-east-1
S3_ACCESS_KEY_ID=minioadmin
S3_SECRET_ACCESS_KEY=minioadmin
S3_BUCKET=voxa-note-audio

MAX_RECORDING_SECONDS=3600
EOF
    echo "✅ Created server/.env"
else
    echo "✅ .env file exists"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Add your OPENAI_API_KEY to server/.env"
echo "2. Create MinIO bucket 'voxa-note-audio' at http://localhost:9001"
echo "3. Restart backend: cd server && npm run dev"
echo "4. Run Flutter app: flutter run -d <device> --dart-define=API_BASE_URL=http://10.0.2.2:4000"

