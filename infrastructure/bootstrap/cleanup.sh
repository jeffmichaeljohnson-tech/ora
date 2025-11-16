#!/bin/bash
# Ora Framework - Infrastructure Cleanup Script
# Removes all infrastructure components for a project instance
#
# Usage: ./cleanup.sh <project-name> [--confirm]
#
# WARNING: This script will DELETE:
# - PostgreSQL schema and all data
# - Pinecone namespace and all vectors
# - Slack channel (archives, doesn't delete)
#
# Use with extreme caution!

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORA_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Configuration
PROJECT_NAME="${1:-}"
CONFIRM="${2:-}"

function print_error() {
    echo -e "${RED}❌ $1${NC}"
}

function print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

function print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

function cleanup_postgresql() {
    local schema_name="ora_${PROJECT_NAME}"
    
    print_warning "Cleaning up PostgreSQL schema: ${schema_name}"
    
    if [ -z "$DB_PASSWORD" ]; then
        export PGPASSWORD="${DB_PASSWORD:-}"
    fi
    
    psql -h "${DB_HOST:-localhost}" -p "${DB_PORT:-5432}" -U "${DB_USER:-postgres}" -d "${DB_NAME:-postgres}" \
        -c "DROP SCHEMA IF EXISTS ${schema_name} CASCADE;" 2>/dev/null || {
        print_error "Failed to drop PostgreSQL schema"
        return 1
    }
    
    print_success "PostgreSQL schema dropped"
    return 0
}

function cleanup_pinecone() {
    print_warning "Cleaning up Pinecone namespace: ${PROJECT_NAME}"
    
    if [ -z "$PINECONE_API_KEY" ]; then
        print_warning "PINECONE_API_KEY not set, skipping Pinecone cleanup"
        return 0
    fi
    
    # Note: Pinecone doesn't have a direct delete namespace API
    # Namespaces are deleted when all vectors are deleted
    print_warning "Pinecone namespace cleanup requires manual vector deletion"
    print_warning "Use Pinecone console or API to delete all vectors in namespace: ${PROJECT_NAME}"
    
    return 0
}

function cleanup_slack() {
    print_warning "Slack channels cannot be deleted via API"
    print_warning "Archive channel manually: #ora-${PROJECT_NAME}-agents"
    return 0
}

function main() {
    if [ -z "$PROJECT_NAME" ]; then
        print_error "Project name is required"
        echo ""
        echo "Usage: $0 <project-name> [--confirm]"
        exit 1
    fi
    
    if [ "$CONFIRM" != "--confirm" ]; then
        print_error "This will DELETE all infrastructure for project: ${PROJECT_NAME}"
        echo ""
        echo "To confirm, run: $0 ${PROJECT_NAME} --confirm"
        exit 1
    fi
    
    echo -e "${RED}${'='*80}"
    echo "  WARNING: INFRASTRUCTURE CLEANUP"
    echo "="*80
    echo -e "${NC}"
    echo "Project: ${PROJECT_NAME}"
    echo ""
    echo "This will DELETE:"
    echo "  - PostgreSQL schema: ora_${PROJECT_NAME} (and all data)"
    echo "  - Pinecone namespace: ${PROJECT_NAME} (requires manual cleanup)"
    echo "  - Slack channel: #ora-${PROJECT_NAME}-agents (archive manually)"
    echo ""
    read -p "Are you absolutely sure? Type 'DELETE' to confirm: " confirmation
    
    if [ "$confirmation" != "DELETE" ]; then
        print_warning "Cleanup cancelled"
        exit 0
    fi
    
    cleanup_postgresql
    cleanup_pinecone
    cleanup_slack
    
    print_success "Cleanup completed (some steps require manual intervention)"
}

main

