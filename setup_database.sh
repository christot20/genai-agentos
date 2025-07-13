#!/bin/bash

# Database Setup Script for GenAI AgentOS
# This script will restore the database schema from the dump file

echo "Setting up database schema for GenAI AgentOS..."

# Check if Docker containers are running
if ! docker ps | grep -q "genai-postgres"; then
    echo "Starting PostgreSQL container..."
    docker-compose up -d postgres
    sleep 10  # Wait for PostgreSQL to start
fi

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
until docker exec genai-postgres pg_isready -U postgres; do
    echo "PostgreSQL is not ready yet. Waiting..."
    sleep 2
done

# Drop and recreate the database
echo "Dropping and recreating database..."
docker exec genai-postgres psql -U postgres -c "DROP DATABASE IF EXISTS postgres;"
docker exec genai-postgres psql -U postgres -c "CREATE DATABASE postgres;"

# Restore the database schema
echo "Restoring database schema from dump..."
docker exec -i genai-postgres psql -U postgres postgres < database_schema_dump.sql

echo "Database setup complete!"
echo "You can now start the full application with: docker-compose up -d" 