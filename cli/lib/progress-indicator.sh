#!/bin/bash
# Progress Indicator Library
# Provides visual feedback during long-running operations

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Track progress steps
STEP_COUNT=0
COMPLETED_STEPS=0
FAILED_STEPS=0

show_progress() {
    local message="$1"
    local detail="${2:-}"
    
    STEP_COUNT=$((STEP_COUNT + 1))
    
    echo -ne "${CYAN}[${STEP_COUNT}]${NC} ${message}"
    if [ -n "$detail" ]; then
        echo -e " ${YELLOW}(${detail})${NC}"
    else
        echo ""
    fi
}

mark_complete() {
    local message="${1:-Completed}"
    COMPLETED_STEPS=$((COMPLETED_STEPS + 1))
    echo -e "  ${GREEN}✅ ${message}${NC}"
}

mark_failed() {
    local message="${1:-Failed}"
    FAILED_STEPS=$((FAILED_STEPS + 1))
    echo -e "  ${RED}❌ ${message}${NC}"
}

show_summary() {
    echo ""
    echo -e "${BLUE}Progress Summary:${NC}"
    echo -e "  ${GREEN}Completed: ${COMPLETED_STEPS}${NC}"
    if [ $FAILED_STEPS -gt 0 ]; then
        echo -e "  ${RED}Failed: ${FAILED_STEPS}${NC}"
    fi
    echo -e "  Total Steps: ${STEP_COUNT}"
}

# Export functions
export -f show_progress
export -f mark_complete
export -f mark_failed
export -f show_summary

