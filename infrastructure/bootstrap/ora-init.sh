#!/bin/bash
# Ora Framework - Complete Infrastructure Bootstrap Script
# Creates all infrastructure components for a new project instance
#
# Usage: ./ora-init.sh <project-name>
#
# This script orchestrates:
# 1. PostgreSQL schema creation
# 2. Pinecone namespace setup
# 3. Slack channel creation
# 4. LangSmith project setup (manual)
# 5. GitHub repository setup (manual)
#
# Environment Variables Required:
#   DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD (PostgreSQL)
#   PINECONE_API_KEY, PINECONE_INDEX_NAME (Pinecone)
#   SLACK_BOT_TOKEN (Slack)
#   LANGSMITH_API_KEY (LangSmith - optional)

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORA_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Infrastructure script paths
POSTGRES_SCRIPT="${ORA_ROOT}/infrastructure/postgres/create-schema.sh"
PINECONE_SCRIPT="${ORA_ROOT}/infrastructure/pinecone/create-namespace.py"
SLACK_SCRIPT="${ORA_ROOT}/infrastructure/slack/create-channel.js"

# Configuration
PROJECT_NAME="${1:-}"
DRY_RUN="${2:-}"

# Track setup steps
SETUP_STEPS=()
FAILED_STEPS=()

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function print_header() {
    echo ""
    echo -e "${GREEN}$(printf '=%.0s' {1..80})"
    echo "  $1"
    echo -e "$(printf '=%.0s' {1..80})${NC}"
    echo ""
}

function print_step() {
    echo -e "${CYAN}▶ $1${NC}"
}

function print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    SETUP_STEPS+=("✅ $1")
}

function print_error() {
    echo -e "${RED}❌ $1${NC}"
    FAILED_STEPS+=("❌ $1")
}

function print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

function print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

function validate_project_name() {
    if [[ ! "$PROJECT_NAME" =~ ^[a-z0-9-]+$ ]]; then
        return 1
    fi
    if [[ "$PROJECT_NAME" =~ ^-|-$ ]]; then
        return 1
    fi
    if [ ${#PROJECT_NAME} -lt 2 ]; then
        return 1
    fi
    return 0
}

function check_dependencies() {
    local missing=()
    
    # Check PostgreSQL script
    if [ ! -f "$POSTGRES_SCRIPT" ]; then
        missing+=("PostgreSQL script: $POSTGRES_SCRIPT")
    fi
    
    # Check Pinecone script
    if [ ! -f "$PINECONE_SCRIPT" ]; then
        missing+=("Pinecone script: $PINECONE_SCRIPT")
    fi
    
    # Check Slack script
    if [ ! -f "$SLACK_SCRIPT" ]; then
        missing+=("Slack script: $SLACK_SCRIPT")
    fi
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        missing+=("python3")
    fi
    
    # Check Node.js (for Slack script)
    if ! command -v node &> /dev/null; then
        missing+=("node")
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_error "Missing dependencies:"
        for dep in "${missing[@]}"; do
            echo "  - $dep"
        done
        return 1
    fi
    
    return 0
}

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

function setup_postgresql() {
    print_step "Setting up PostgreSQL schema..."
    
    if [ "$DRY_RUN" = "--dry-run" ]; then
        print_info "DRY RUN: Would execute: $POSTGRES_SCRIPT $PROJECT_NAME"
        print_success "PostgreSQL schema (dry run)"
        return 0
    fi
    
    if [ ! -f "$POSTGRES_SCRIPT" ]; then
        print_error "PostgreSQL script not found: $POSTGRES_SCRIPT"
        return 1
    fi
    
    if bash "$POSTGRES_SCRIPT" "$PROJECT_NAME"; then
        print_success "PostgreSQL schema created: ora_${PROJECT_NAME}"
        return 0
    else
        print_error "PostgreSQL schema creation failed"
        return 1
    fi
}

function setup_pinecone() {
    print_step "Setting up Pinecone namespace..."
    
    if [ "$DRY_RUN" = "--dry-run" ]; then
        print_info "DRY RUN: Would execute: python3 $PINECONE_SCRIPT $PROJECT_NAME"
        print_success "Pinecone namespace (dry run)"
        return 0
    fi
    
    if [ ! -f "$PINECONE_SCRIPT" ]; then
        print_error "Pinecone script not found: $PINECONE_SCRIPT"
        return 1
    fi
    
    if [ -z "$PINECONE_API_KEY" ]; then
        print_warning "PINECONE_API_KEY not set, skipping Pinecone setup"
        return 0
    fi
    
    if python3 "$PINECONE_SCRIPT" "$PROJECT_NAME"; then
        print_success "Pinecone namespace created: ${PROJECT_NAME}"
        return 0
    else
        print_error "Pinecone namespace creation failed"
        return 1
    fi
}

function setup_slack() {
    print_step "Setting up Slack channel..."
    
    if [ "$DRY_RUN" = "--dry-run" ]; then
        print_info "DRY RUN: Would execute: node $SLACK_SCRIPT $PROJECT_NAME"
        print_success "Slack channel (dry run)"
        return 0
    fi
    
    if [ ! -f "$SLACK_SCRIPT" ]; then
        print_error "Slack script not found: $SLACK_SCRIPT"
        return 1
    fi
    
    if [ -z "$SLACK_BOT_TOKEN" ]; then
        print_warning "SLACK_BOT_TOKEN not set, skipping Slack setup"
        return 0
    fi
    
    # Check if node modules are installed
    SLACK_DIR="$(dirname "$SLACK_SCRIPT")"
    if [ ! -d "$SLACK_DIR/node_modules" ]; then
        print_info "Installing Node.js dependencies..."
        (cd "$SLACK_DIR" && npm install @slack/web-api 2>/dev/null || true)
    fi
    
    if node "$SLACK_SCRIPT" "$PROJECT_NAME"; then
        print_success "Slack channel created: #ora-${PROJECT_NAME}-agents"
        return 0
    else
        print_error "Slack channel creation failed"
        return 1
    fi
}

function print_manual_steps() {
    print_header "MANUAL SETUP STEPS"
    
    echo -e "${YELLOW}The following steps require manual intervention:${NC}"
    echo ""
    
    echo -e "${CYAN}1. LangSmith Project Setup${NC}"
    echo "   - Navigate to: https://smith.langchain.com/projects"
    echo "   - Create project: ${PROJECT_NAME}"
    echo "   - Description: Ora Framework - ${PROJECT_NAME} autonomous agent system"
    echo "   - See: ${ORA_ROOT}/infrastructure/langsmith/setup-project.md"
    echo ""
    
    echo -e "${CYAN}2. GitHub Repository Setup${NC}"
    echo "   - Create repository: ${PROJECT_NAME}"
    echo "   - Description: Ora Framework - ${PROJECT_NAME} autonomous agent system"
    echo "   - See: ${ORA_ROOT}/infrastructure/github/repo-template.md"
    echo ""
    
    echo -e "${CYAN}3. Environment Variables${NC}"
    echo "   Create .env file with:"
    echo "   PROJECT_NAME=${PROJECT_NAME}"
    echo "   POSTGRES_SCHEMA=ora_${PROJECT_NAME}"
    echo "   PINECONE_NAMESPACE=${PROJECT_NAME}"
    echo "   SLACK_CHANNEL=ora-${PROJECT_NAME}-agents"
    echo "   LANGSMITH_PROJECT=${PROJECT_NAME}"
    echo ""
}

function print_summary() {
    print_header "SETUP SUMMARY"
    
    echo -e "${GREEN}Completed Steps:${NC}"
    for step in "${SETUP_STEPS[@]}"; do
        echo "  $step"
    done
    
    if [ ${#FAILED_STEPS[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}Failed Steps:${NC}"
        for step in "${FAILED_STEPS[@]}"; do
            echo "  $step"
        done
    fi
    
    echo ""
    echo -e "${CYAN}Project Configuration:${NC}"
    echo "  Project Name:     ${PROJECT_NAME}"
    echo "  PostgreSQL Schema: ora_${PROJECT_NAME}"
    echo "  Pinecone Namespace: ${PROJECT_NAME}"
    echo "  Slack Channel:   #ora-${PROJECT_NAME}-agents"
    echo "  LangSmith Project: ${PROJECT_NAME} (manual)"
    echo "  GitHub Repo:     ${PROJECT_NAME} (manual)"
    echo ""
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function main() {
    # Validate inputs
    if [ -z "$PROJECT_NAME" ]; then
        echo -e "${RED}❌ Error: Project name is required${NC}"
        echo ""
        echo "Usage: $0 <project-name> [--dry-run]"
        echo ""
        echo "Example:"
        echo "  $0 my-awesome-project"
        echo ""
        echo "Options:"
        echo "  --dry-run    Show what would be done without executing"
        exit 1
    fi
    
    if ! validate_project_name; then
        print_error "Invalid project name format"
        echo ""
        echo "Project name must be:"
        echo "  - Lowercase only"
        echo "  - Alphanumeric and hyphens only"
        echo "  - Cannot start/end with hyphen"
        echo "  - Example: 'my-project' or 'awesome-app'"
        exit 1
    fi
    
    # Check dependencies
    if ! check_dependencies; then
        exit 1
    fi
    
    # Print header
    print_header "ORA FRAMEWORK - INFRASTRUCTURE BOOTSTRAP"
    echo "Project: ${CYAN}${PROJECT_NAME}${NC}"
    echo "Mode: ${YELLOW}${DRY_RUN:-Normal}${NC}"
    echo ""
    
    # Run setup steps
    local failed=0
    
    setup_postgresql || failed=1
    setup_pinecone || failed=1
    setup_slack || failed=1
    
    # Print manual steps
    print_manual_steps
    
    # Print summary
    print_summary
    
    # Exit with appropriate code
    if [ $failed -eq 0 ] && [ ${#FAILED_STEPS[@]} -eq 0 ]; then
        print_success "Infrastructure bootstrap completed successfully!"
        exit 0
    else
        print_error "Some setup steps failed. Review errors above."
        exit 1
    fi
}

# Run main function
main

