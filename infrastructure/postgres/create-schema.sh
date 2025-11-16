#!/bin/bash
# PostgreSQL Schema Creation Script for Ora Framework
# Creates isolated schema for new project instances

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="${1:-}"
DB_HOST="${DB_HOST:-localhost}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-postgres}"
DB_USER="${DB_USER:-postgres}"

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA_TEMPLATE="${SCRIPT_DIR}/schema-template.sql"

# ============================================================================
# VALIDATION
# ============================================================================

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}❌ Error: PROJECT_NAME is required${NC}"
    echo ""
    echo "Usage: $0 <project-name>"
    echo ""
    echo "Example:"
    echo "  $0 my-awesome-project"
    echo ""
    echo "This will create schema: ora_my-awesome-project"
    exit 1
fi

# Validate project name format (lowercase, alphanumeric, hyphens only)
if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
    echo -e "${RED}❌ Error: Invalid project name format${NC}"
    echo ""
    echo "Project name must be:"
    echo "  - Lowercase only"
    echo "  - Alphanumeric and hyphens only"
    echo "  - Example: 'my-project' or 'awesome-app'"
    exit 1
fi

if [ ! -f "$SCHEMA_TEMPLATE" ]; then
    echo -e "${RED}❌ Error: Schema template not found: $SCHEMA_TEMPLATE${NC}"
    exit 1
fi

# Check if psql is available
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ Error: psql command not found${NC}"
    echo "Install PostgreSQL client tools to continue"
    exit 1
fi

# ============================================================================
# SCHEMA CREATION
# ============================================================================

SCHEMA_NAME="ora_${PROJECT_NAME}"
TEMP_SQL=$(mktemp)

echo -e "${GREEN}================================================================================"
echo "  POSTGRESQL SCHEMA CREATION"
echo "================================================================================"
echo ""
echo "Project Name: ${YELLOW}${PROJECT_NAME}${NC}"
echo "Schema Name:  ${YELLOW}${SCHEMA_NAME}${NC}"
echo "Database:     ${YELLOW}${DB_NAME}${NC}"
echo "Host:         ${YELLOW}${DB_HOST}:${DB_PORT}${NC}"
echo "User:         ${YELLOW}${DB_USER}${NC}"
echo "================================================================================"
echo ""

# Replace template variables
sed "s/{{PROJECT_NAME}}/${PROJECT_NAME}/g" "$SCHEMA_TEMPLATE" > "$TEMP_SQL"

# Prompt for password if needed
export PGPASSWORD="${DB_PASSWORD:-}"

# Check if schema already exists
SCHEMA_EXISTS=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
    "SELECT EXISTS(SELECT 1 FROM information_schema.schemata WHERE schema_name = '${SCHEMA_NAME}');" 2>/dev/null || echo "false")

if [ "$SCHEMA_EXISTS" = "t" ]; then
    echo -e "${YELLOW}⚠️  Schema '${SCHEMA_NAME}' already exists${NC}"
    read -p "Do you want to drop and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Dropping existing schema...${NC}"
        psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -c "DROP SCHEMA IF EXISTS ${SCHEMA_NAME} CASCADE;" || {
            echo -e "${RED}❌ Failed to drop schema${NC}"
            rm -f "$TEMP_SQL"
            exit 1
        }
    else
        echo -e "${YELLOW}Skipping schema creation${NC}"
        rm -f "$TEMP_SQL"
        exit 0
    fi
fi

# Create schema
echo -e "${GREEN}Creating schema and tables...${NC}"
psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -f "$TEMP_SQL" || {
    echo -e "${RED}❌ Failed to create schema${NC}"
    rm -f "$TEMP_SQL"
    exit 1
}

# Verify creation
TABLE_COUNT=$(psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" -tAc \
    "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '${SCHEMA_NAME}';" 2>/dev/null || echo "0")

# Cleanup
rm -f "$TEMP_SQL"

# ============================================================================
# SUCCESS
# ============================================================================

echo ""
echo -e "${GREEN}✅ Schema created successfully!${NC}"
echo ""
echo "Schema Details:"
echo "  Name: ${SCHEMA_NAME}"
echo "  Tables: ${TABLE_COUNT}"
echo ""
echo "Connection String:"
echo "  postgresql://${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME}?options=-csearch_path%3D${SCHEMA_NAME}"
echo ""
echo "Next Steps:"
echo "  1. Update your application to use schema: ${SCHEMA_NAME}"
echo "  2. Set search_path in connection: SET search_path TO ${SCHEMA_NAME}, public;"
echo "  3. Configure Pinecone namespace for project isolation"
echo "  4. Create Slack channel: #${PROJECT_NAME}-agents"
echo ""

