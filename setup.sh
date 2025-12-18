#!/bin/bash
set -e

echo "🚀 Setting up VoxaNote backend..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker Desktop from https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ docker-compose is not available. Please install Docker Desktop."
    exit 1
fi

# Start Postgres and MinIO
echo "📦 Starting Postgres and MinIO containers..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

# Wait for Postgres to be ready
echo "⏳ Waiting for Postgres to be ready..."
sleep 5

# Run migrations
echo "📊 Running database migrations..."
export PGPASSWORD=voxa_pass
psql -h localhost -U voxa_user -d voxa_note -f server/migrations/001_init.sql 2>/dev/null || {
    echo "⚠️  psql not found. Installing via Docker..."
    docker exec -i voxanote-postgres-1 psql -U voxa_user -d voxa_note < server/migrations/001_init.sql || \
    docker exec -i $(docker ps -q -f name=postgres) psql -U voxa_user -d voxa_note < server/migrations/001_init.sql
}

# Create MinIO bucket (if mc is available, otherwise manual step)
echo "📦 Setting up MinIO bucket..."
if command -v mc &> /dev/null; then
    mc alias set local http://localhost:9000 minioadmin minioadmin 2>/dev/null || true
    mc mb local/voxa-note-audio --ignore-existing 2>/dev/null || true
    echo "✅ MinIO bucket created"
else
    echo "ℹ️  MinIO is running. Create bucket 'voxa-note-audio' via http://localhost:9001"
    echo "   Login: minioadmin / minioadmin"
fi

# Create .env file if it doesn't exist
if [ ! -f server/.env ]; then
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
    echo "✅ Created server/.env file"
    echo "⚠️  IMPORTANT: Edit server/.env and add your OPENAI_API_KEY"
else
    echo "✅ .env file already exists"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit server/.env and add your OPENAI_API_KEY"
echo "2. If MinIO bucket wasn't created, visit http://localhost:9001 and create 'voxa-note-audio'"
echo "3. Start the backend: cd server && npm run dev"
echo "4. Run the Flutter app with: flutter run -d <device> --dart-define=API_BASE_URL=http://10.0.2.2:4000"

