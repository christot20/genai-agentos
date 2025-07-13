# Database Setup Instructions

## For Friends/Team Members

I've updated the database schema with new tables/columns. To get the updated schema:

### Option 1: Quick Setup (Recommended)
```bash
# 1. Pull the latest changes
git pull origin main

# 2. Run the database setup script
./setup_database.sh

# 3. Start the full application
docker-compose up -d
```

### Option 2: Manual Setup
If the script doesn't work, you can manually restore the database:

```bash
# 1. Start PostgreSQL
docker-compose up -d postgres

# 2. Wait for PostgreSQL to be ready
docker exec genai-postgres pg_isready -U postgres

# 3. Drop and recreate database
docker exec genai-postgres psql -U postgres -c "DROP DATABASE IF EXISTS postgres;"
docker exec genai-postgres psql -U postgres -c "CREATE DATABASE postgres;"

# 4. Restore from dump
docker exec -i genai-postgres psql -U postgres postgres < database_schema_dump.sql

# 5. Start the full application
docker-compose up -d
```

### What's Included
- `database_schema_dump.sql` - Complete database schema with all tables and data
- `setup_database.sh` - Automated setup script
- This README with instructions

### Troubleshooting
- If you get permission errors, make sure Docker is running
- If the script fails, try the manual setup steps
- Make sure you're in the project root directory when running commands

### Note
This will completely replace your local database with the updated schema. Any local data will be lost. 