#!/bin/bash
# Rollback and Cleanup Library
# Handles cleanup of partially created resources on failure

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

rollback_cleanup() {
    local rollback_log="$1"
    
    if [ ! -f "$rollback_log" ]; then
        return 0
    fi
    
    echo ""
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${RED}ROLLBACK: Cleaning up partially created resources${NC}"
    echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Read rollback log
    local project_name=""
    local project_dir=""
    local postgres_schema=""
    local github_repo=""
    
    while IFS='=' read -r key value; do
        case "$key" in
            PROJECT_NAME)
                project_name="$value"
                ;;
            PROJECT_DIR)
                project_dir="$value"
                ;;
            POSTGRES_SCHEMA)
                postgres_schema="$value"
                ;;
            GITHUB_REPO)
                github_repo="$value"
                ;;
        esac
    done < "$rollback_log"
    
    # Cleanup PostgreSQL schema
    if [ -n "$postgres_schema" ]; then
        echo -e "${YELLOW}Cleaning up PostgreSQL schema: ${postgres_schema}${NC}"
        psql -h "${DB_HOST:-localhost}" -p "${DB_PORT:-5432}" -U "${DB_USER:-postgres}" -d "${DB_NAME:-postgres}" \
            -c "DROP SCHEMA IF EXISTS ${postgres_schema} CASCADE;" 2>/dev/null || true
    fi
    
    # Cleanup project directory
    if [ -n "$project_dir" ] && [ -d "$project_dir" ]; then
        echo -e "${YELLOW}Cleaning up project directory: ${project_dir}${NC}"
        rm -rf "$project_dir"
    fi
    
    # Note: Pinecone namespace and Slack channel cleanup would require API calls
    # For now, we'll just log them
    if [ -n "$project_name" ]; then
        echo -e "${YELLOW}Note: Manual cleanup may be needed for:${NC}"
        echo "  - Pinecone namespace: ${project_name}"
        echo "  - Slack channel: #ora-${project_name}-agents"
    fi
    
    # Remove rollback log
    rm -f "$rollback_log"
    
    echo ""
    echo -e "${RED}Rollback complete${NC}"
    echo ""
}

# Export function
export -f rollback_cleanup

