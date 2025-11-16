#!/bin/bash
# Project Name Validation Library
# Validates project names according to Ora Framework conventions

validate_project_name() {
    local project_name="$1"
    
    # Check if empty
    if [ -z "$project_name" ]; then
        return 1
    fi
    
    # Check length (minimum 2 characters)
    if [ ${#project_name} -lt 2 ]; then
        return 1
    fi
    
    # Check if starts or ends with hyphen
    if [[ "$project_name" =~ ^- ]] || [[ "$project_name" =~ -$ ]]; then
        return 1
    fi
    
    # Check format: lowercase, alphanumeric, hyphens only
    if [[ ! "$project_name" =~ ^[a-z0-9-]+$ ]]; then
        return 1
    fi
    
    # Check for consecutive hyphens
    if [[ "$project_name" =~ -- ]]; then
        return 1
    fi
    
    return 0
}

# Export function
export -f validate_project_name

