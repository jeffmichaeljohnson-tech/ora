#!/bin/bash
#
# ora-hire-agent - Deploy a new agent to an Ora project
#
# Usage: ora-hire-agent <project-name> <archetype> <agent-number> [options]
#
# Examples:
#   ora-hire-agent my-project research-agent 35
#   ora-hire-agent my-project implementation-agent 36 --track "Feature X"
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORA_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATES_DIR="$ORA_ROOT/agent-templates/archetypes"
PROJECTS_ROOT="$ORA_ROOT/../projects"

# Default values
PROJECT_NAME=""
ARCHETYPE=""
AGENT_NUMBER=""
TRACK_NAME=""
TASK_TITLE=""
TASK_DESCRIPTION=""
OUTPUT_LOCATION=""
TIMELINE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --track)
            TRACK_NAME="$2"
            shift 2
            ;;
        --title)
            TASK_TITLE="$2"
            shift 2
            ;;
        --description)
            TASK_DESCRIPTION="$2"
            shift 2
            ;;
        --output)
            OUTPUT_LOCATION="$2"
            shift 2
            ;;
        --timeline)
            TIMELINE="$2"
            shift 2
            ;;
        --help|-h)
            cat << EOF
ora-hire-agent - Deploy a new agent to an Ora project

Usage: ora-hire-agent <project-name> <archetype> <agent-number> [options]

Arguments:
  project-name    Name of the Ora project (e.g., 'my-project')
  archetype       Agent archetype (research-agent, implementation-agent, qa-agent, documentation-agent, infrastructure-agent)
  agent-number    Agent number (e.g., 35)

Options:
  --track NAME              Track or feature area name
  --title TITLE             Task title
  --description DESC        Task description
  --output PATH             Output location for deliverables
  --timeline TIMELINE       Expected timeline (e.g., 'Complete in 15 minutes')
  --help, -h                Show this help message

Examples:
  ora-hire-agent my-project research-agent 35 --track "Memory Architecture"
  ora-hire-agent my-project implementation-agent 36 --title "Build Feature X" --timeline "2 hours"

Available Archetypes:
  - research-agent          Deep research on best practices, competitive analysis
  - implementation-agent    Build features, write code, create infrastructure
  - qa-agent                Test deliverables, validate quality, ensure standards
  - documentation-agent     Write guides, create tutorials, maintain knowledge base
  - infrastructure-agent    Set up services, configure environments, optimize performance
EOF
            exit 0
            ;;
        *)
            if [[ -z "$PROJECT_NAME" ]]; then
                PROJECT_NAME="$1"
            elif [[ -z "$ARCHETYPE" ]]; then
                ARCHETYPE="$1"
            elif [[ -z "$AGENT_NUMBER" ]]; then
                AGENT_NUMBER="$1"
            else
                echo -e "${RED}Error: Unknown argument: $1${NC}" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$PROJECT_NAME" ]] || [[ -z "$ARCHETYPE" ]] || [[ -z "$AGENT_NUMBER" ]]; then
    echo -e "${RED}Error: Missing required arguments${NC}" >&2
    echo "Usage: ora-hire-agent <project-name> <archetype> <agent-number> [options]"
    echo "Run 'ora-hire-agent --help' for more information"
    exit 1
fi

# Validate archetype
if [[ ! -f "$TEMPLATES_DIR/$ARCHETYPE.json" ]]; then
    echo -e "${RED}Error: Archetype '$ARCHETYPE' not found${NC}" >&2
    echo "Available archetypes:"
    ls -1 "$TEMPLATES_DIR"/*.json | xargs -n1 basename | sed 's/.json$//' | sed 's/^/  - /'
    exit 1
fi

# Set defaults if not provided
TRACK_NAME="${TRACK_NAME:-$PROJECT_NAME}"
TASK_TITLE="${TASK_TITLE:-Agent $AGENT_NUMBER - $ARCHETYPE}"
TASK_DESCRIPTION="${TASK_DESCRIPTION:-Deploy $ARCHETYPE for $PROJECT_NAME project}"
OUTPUT_LOCATION="${OUTPUT_LOCATION:-$PROJECTS_ROOT/$PROJECT_NAME/agents/agent-$AGENT_NUMBER/deliverables}"
TIMELINE="${TIMELINE:-Complete in 20 minutes}"

# Generate timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create project directory structure
PROJECT_DIR="$PROJECTS_ROOT/$PROJECT_NAME"
AGENT_DIR="$PROJECT_DIR/agents/agent-$AGENT_NUMBER"
QUEUE_DIR="$PROJECT_DIR/agents/_queue"

echo -e "${BLUE}🚀 Deploying agent-$AGENT_NUMBER ($ARCHETYPE) to $PROJECT_NAME...${NC}"

# Create directory structure
mkdir -p "$AGENT_DIR/deliverables"
mkdir -p "$QUEUE_DIR/inbox"
mkdir -p "$QUEUE_DIR/outbox"
mkdir -p "$QUEUE_DIR/processed"
mkdir -p "$QUEUE_DIR/failed"

echo -e "${GREEN}✅ Created directory structure${NC}"

# Read template
TEMPLATE=$(cat "$TEMPLATES_DIR/$ARCHETYPE.json")

# Replace template variables
TASK_FILE="$QUEUE_DIR/inbox/task-agent-$AGENT_NUMBER.json"

# Use sed to replace variables (more reliable than envsubst for JSON)
TASK_CONTENT=$(echo "$TEMPLATE" | \
    sed "s/{{AGENT_NUMBER}}/$AGENT_NUMBER/g" | \
    sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" | \
    sed "s/{{TRACK_NAME}}/$TRACK_NAME/g" | \
    sed "s|{{OUTPUT_LOCATION}}|$OUTPUT_LOCATION|g" | \
    sed "s/{{TIMESTAMP}}/$TIMESTAMP/g" | \
    sed "s/{{TASK_TITLE}}/$TASK_TITLE/g" | \
    sed "s|{{TASK_DESCRIPTION}}|$TASK_DESCRIPTION|g" | \
    sed "s/{{TIMELINE}}/$TIMELINE/g" | \
    sed "s/#{{PROJECT_NAME}}-agents/#$PROJECT_NAME-agents/g")

# Write task file
echo "$TASK_CONTENT" > "$TASK_FILE"

echo -e "${GREEN}✅ Created task file: $TASK_FILE${NC}"

# Create agent configuration file
CONFIG_FILE="$AGENT_DIR/config.json"
cat > "$CONFIG_FILE" << EOF
{
  "agentId": "agent-$AGENT_NUMBER",
  "archetype": "$ARCHETYPE",
  "projectName": "$PROJECT_NAME",
  "trackName": "$TRACK_NAME",
  "created": "$TIMESTAMP",
  "status": "active",
  "queueDir": "$QUEUE_DIR"
}
EOF

echo -e "${GREEN}✅ Created agent configuration: $CONFIG_FILE${NC}"

# Create agent workflow helper
WORKFLOW_FILE="$AGENT_DIR/agent-workflow.js"
cat > "$WORKFLOW_FILE" << 'EOF'
/**
 * Agent Workflow Helper
 * Provides utilities for agent operations
 */

const fs = require('fs');
const path = require('path');
const config = require('./config.json');

// Import communication helper
const comm = require('../_queue/agent-communication');

/**
 * Read task from inbox
 */
function readTask() {
    const taskFile = path.join(config.queueDir, 'inbox', `task-${config.agentId}.json`);
    
    if (!fs.existsSync(taskFile)) {
        // Try to find any task file for this agent
        const inboxDir = path.join(config.queueDir, 'inbox');
        const files = fs.readdirSync(inboxDir)
            .filter(f => f.includes(config.agentId) && f.endsWith('.json'));
        
        if (files.length === 0) {
            return null;
        }
        
        const content = fs.readFileSync(path.join(inboxDir, files[0]), 'utf8');
        return JSON.parse(content);
    }
    
    const content = fs.readFileSync(taskFile, 'utf8');
    return JSON.parse(content);
}

/**
 * Mark task as processed
 */
function markTaskProcessed(taskId) {
    const inboxDir = path.join(config.queueDir, 'inbox');
    const processedDir = path.join(config.queueDir, 'processed');
    
    const files = fs.readdirSync(inboxDir)
        .filter(f => f.includes(taskId) && f.endsWith('.json'));
    
    if (files.length > 0) {
        const source = path.join(inboxDir, files[0]);
        const dest = path.join(processedDir, files[0]);
        fs.renameSync(source, dest);
        return true;
    }
    
    return false;
}

/**
 * Update agent status
 */
function updateStatus(status) {
    config.status = status;
    config.lastUpdate = new Date().toISOString();
    
    const configFile = path.join(__dirname, 'config.json');
    fs.writeFileSync(configFile, JSON.stringify(config, null, 2));
}

module.exports = {
    readTask,
    markTaskProcessed,
    updateStatus,
    comm,
    config
};
EOF

echo -e "${GREEN}✅ Created agent workflow helper: $WORKFLOW_FILE${NC}"

# Create agent communication helper (symlink or copy)
COMM_FILE="$QUEUE_DIR/agent-communication.js"
if [[ ! -f "$COMM_FILE" ]]; then
    # Copy from templates if available, otherwise create basic version
    if [[ -f "$ORA_ROOT/agent-templates/deploy/agent-communication.js" ]]; then
        cp "$ORA_ROOT/agent-templates/deploy/agent-communication.js" "$COMM_FILE"
    else
        # Create basic version
        cat > "$COMM_FILE" << 'COMMEOF'
/**
 * Agent Communication Helper
 * Copy from MCP-WP or use Ora framework version
 */

const fs = require('fs');
const path = require('path');

const OUTBOX_DIR = path.join(__dirname, 'outbox');

function postMessage(agentId, content, messageType = 'update', priority = 'normal', metadata = {}) {
    if (!fs.existsSync(OUTBOX_DIR)) {
        fs.mkdirSync(OUTBOX_DIR, { recursive: true });
    }
    
    const timestamp = Date.now();
    const messageId = `msg-${timestamp}-${Math.random().toString(36).substr(2, 9)}`;
    
    const message = {
        id: messageId,
        agentId: agentId,
        timestamp: new Date().toISOString(),
        messageType: messageType,
        priority: priority,
        content: content,
        metadata: metadata
    };
    
    const filename = `${messageId}.json`;
    const filepath = path.join(OUTBOX_DIR, filename);
    
    fs.writeFileSync(filepath, JSON.stringify(message, null, 2));
    return { success: true, messageId, filepath };
}

function postUpdate(agentId, content, metadata = {}) {
    return postMessage(agentId, content, 'update', 'normal', metadata);
}

function postMilestone(agentId, milestoneName, details, metadata = {}) {
    const content = `🎯 Milestone Completed: ${milestoneName}\n\n${details}`;
    return postMessage(agentId, content, 'milestone', 'high', metadata);
}

function postBlocker(agentId, blockerDescription, metadata = {}) {
    const content = `🚨 BLOCKER: ${blockerDescription}`;
    return postMessage(agentId, content, 'blocker', 'urgent', metadata);
}

module.exports = {
    postMessage,
    postUpdate,
    postMilestone,
    postBlocker
};
COMMEOF
    fi
    echo -e "${GREEN}✅ Created communication helper: $COMM_FILE${NC}"
fi

# Summary
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Agent deployment complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""
echo "Agent Details:"
echo "  Agent ID: agent-$AGENT_NUMBER"
echo "  Archetype: $ARCHETYPE"
echo "  Project: $PROJECT_NAME"
echo "  Track: $TRACK_NAME"
echo ""
echo "Files Created:"
echo "  Task File: $TASK_FILE"
echo "  Config: $CONFIG_FILE"
echo "  Workflow: $WORKFLOW_FILE"
echo ""
echo "Next Steps:"
echo "  1. Review task file: $TASK_FILE"
echo "  2. Agent will read task from inbox and begin work"
echo "  3. Monitor progress in Slack: #$PROJECT_NAME-agents"
echo ""

