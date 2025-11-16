# Ora Framework - Agent Templates Guide

**Complete guide to using and creating agent templates in Ora.**

---

## Table of Contents

1. [Overview](#overview)
2. [Available Agent Types](#available-agent-types)
3. [Using Agent Templates](#using-agent-templates)
4. [Creating Custom Agents](#creating-custom-agents)
5. [Template Schema](#template-schema)
6. [Best Practices](#best-practices)

---

## Overview

Agent templates are reusable JSON files that define agent archetypes. They enable rapid deployment of agents for any Ora project with zero manual configuration.

### Key Benefits

- ✅ **Instant Deployment**: Deploy agents in seconds
- ✅ **Consistent Patterns**: Proven patterns from production
- ✅ **Zero Configuration**: Works out of the box
- ✅ **Customizable**: Easy to modify for your needs
- ✅ **Reusable**: Use across multiple projects

---

## Available Agent Types

Ora comes with 5 pre-built agent archetypes:

### 1. Research Agent

**Purpose:** Deep research, competitive analysis, best practices

**Use Cases:**
- Research technology stacks
- Analyze competitor solutions
- Document best practices
- Create research catalogs

**Template:** `agent-templates/archetypes/research-agent.json`

**Example Tasks:**
- "Research best practices for autonomous agent systems"
- "Analyze competitive landscape for vector databases"
- "Document patterns for multi-project isolation"

---

### 2. Implementation Agent

**Purpose:** Build features, write code, create infrastructure

**Use Cases:**
- Implement new features
- Write code and tests
- Create infrastructure components
- Build integrations

**Template:** `agent-templates/archetypes/implementation-agent.json`

**Example Tasks:**
- "Implement user authentication system"
- "Create API endpoints for data access"
- "Build database migration scripts"

---

### 3. QA Agent

**Purpose:** Test deliverables, validate quality, ensure standards

**Use Cases:**
- Test new features
- Validate code quality
- Ensure standards compliance
- Create test reports

**Template:** `agent-templates/archetypes/qa-agent.json`

**Example Tasks:**
- "Test user authentication system"
- "Validate API endpoints"
- "Check code quality standards"

---

### 4. Documentation Agent

**Purpose:** Write guides, create tutorials, maintain knowledge base

**Use Cases:**
- Create user documentation
- Write API documentation
- Maintain knowledge base
- Create tutorials

**Template:** `agent-templates/archetypes/documentation-agent.json`

**Example Tasks:**
- "Create user guide for authentication"
- "Document API endpoints"
- "Write troubleshooting guide"

---

### 5. Infrastructure Agent

**Purpose:** Set up services, configure environments, optimize performance

**Use Cases:**
- Set up infrastructure
- Configure environments
- Optimize performance
- Manage deployments

**Template:** `agent-templates/archetypes/infrastructure-agent.json`

**Example Tasks:**
- "Set up CI/CD pipeline"
- "Configure production environment"
- "Optimize database performance"

---

## Using Agent Templates

### Deploy an Agent

```bash
# Navigate to deploy directory
cd agent-templates/deploy

# Deploy agent using template
./ora-hire-agent.sh <agent-type> <project-name>

# Examples:
./ora-hire-agent.sh research-agent my-project
./ora-hire-agent.sh implementation-agent my-project
./ora-hire-agent.sh qa-agent my-project
```

### What Happens

1. ✅ Template copied to project directory
2. ✅ Variables replaced with project values
3. ✅ Agent directory structure created
4. ✅ Inbox/outbox directories set up
5. ✅ Agent ready to receive tasks

### Agent Directory Structure

```
projects/my-project/agents/
└── agent-1-research/
    ├── inbox/          # Tasks assigned to agent
    ├── outbox/         # Agent outputs
    ├── processed/      # Completed tasks
    ├── logs/           # Agent logs
    └── config.json     # Agent configuration
```

---

## Creating Custom Agents

### Step 1: Copy Template

```bash
# Copy existing template
cp agent-templates/archetypes/research-agent.json \
   agent-templates/archetypes/my-custom-agent.json
```

### Step 2: Customize Template

Edit the template file:

```json
{
  "agentId": "agent-{{AGENT_NUMBER}}",
  "priority": "HIGH",
  "messageType": "NEW_TASK_ASSIGNMENT",
  "task": {
    "title": "{{TASK_TITLE}}",
    "description": "{{TASK_DESCRIPTION}}",
    "objective": "{{OBJECTIVE}}",
    "context": {
      "projectName": "{{PROJECT_NAME}}",
      "trackName": "{{TRACK_NAME}}"
    },
    "phases": [
      {
        "phase": 1,
        "name": "Custom Phase",
        "duration": "{{PHASE_DURATION}}",
        "tasks": [
          "Your custom task 1",
          "Your custom task 2"
        ],
        "deliverable": "{{DELIVERABLE_PATH}}/output.md"
      }
    ],
    "successCriteria": {
      "mustHave": [
        "Your success criteria"
      ]
    }
  }
}
```

### Step 3: Add to Deploy Script

Edit `agent-templates/deploy/ora-hire-agent.sh`:

```bash
case "$AGENT_TYPE" in
  research-agent)
    TEMPLATE="research-agent.json"
    ;;
  my-custom-agent)
    TEMPLATE="my-custom-agent.json"
    ;;
  *)
    echo "Unknown agent type: $AGENT_TYPE"
    exit 1
    ;;
esac
```

### Step 4: Deploy

```bash
./ora-hire-agent.sh my-custom-agent my-project
```

---

## Template Schema

All agent templates follow a standard schema defined in `agent-templates/schemas/task-schema.json`.

### Required Fields

```json
{
  "agentId": "agent-{{AGENT_NUMBER}}",
  "priority": "HIGH|NORMAL|LOW",
  "messageType": "NEW_TASK_ASSIGNMENT",
  "timestamp": "{{TIMESTAMP}}",
  "task": {
    "title": "{{TASK_TITLE}}",
    "description": "{{TASK_DESCRIPTION}}",
    "objective": "{{OBJECTIVE}}",
    "context": {
      "projectName": "{{PROJECT_NAME}}",
      "trackName": "{{TRACK_NAME}}",
      "strategy": "{{STRATEGY}}",
      "timeline": "{{TIMELINE}}",
      "outputLocation": "{{OUTPUT_LOCATION}}"
    },
    "phases": [...],
    "successCriteria": {...},
    "technicalRequirements": {...},
    "escalation": {...},
    "heartbeat": {...}
  },
  "metadata": {...}
}
```

### Template Variables

Variables are replaced during deployment:

- `{{AGENT_NUMBER}}` → Agent number (e.g., "1", "2")
- `{{PROJECT_NAME}}` → Project name (e.g., "my-project")
- `{{TRACK_NAME}}` → Track name (e.g., "Authentication")
- `{{TIMESTAMP}}` → Current timestamp (ISO 8601)
- `{{TASK_TITLE}}` → Task title
- `{{TASK_DESCRIPTION}}` → Task description
- `{{OBJECTIVE}}` → Task objective
- `{{STRATEGY}}` → Strategic approach
- `{{TIMELINE}}` → Expected timeline
- `{{OUTPUT_LOCATION}}` → Output directory path
- `{{PHASE_DURATION}}` → Phase duration
- `{{DELIVERABLE_PATH}}` → Deliverable path

---

## Best Practices

### 1. Clear Objectives

Define clear, measurable objectives:

```json
"objective": "Create comprehensive research document on vector databases with 50+ sources, categorized findings, and actionable recommendations"
```

### 2. Phased Approach

Break tasks into phases:

```json
"phases": [
  {
    "phase": 1,
    "name": "Research",
    "tasks": ["Research topic", "Document findings"],
    "deliverable": "docs/research.md"
  },
  {
    "phase": 2,
    "name": "Analysis",
    "tasks": ["Analyze findings", "Create recommendations"],
    "deliverable": "docs/analysis.md"
  }
]
```

### 3. Success Criteria

Define clear success criteria:

```json
"successCriteria": {
  "mustHave": [
    "All phases completed",
    "Deliverables created",
    "Quality standards met"
  ],
  "quality": {
    "targetAccuracy": "100%",
    "completeness": "All requirements met",
    "documentation": "Clear and comprehensive"
  }
}
```

### 4. Escalation Rules

Define escalation rules:

```json
"escalation": {
  "blockerThreshold": "20 minutes",
  "escalateTo": "Director (Claude)",
  "autoEscalateIf": [
    "Task failing repeatedly",
    "Cannot access required resources",
    "Missing critical information"
  ]
}
```

### 5. Heartbeat Reporting

Configure heartbeat reporting:

```json
"heartbeat": {
  "frequency": "Every 5 minutes",
  "reportTo": "#{{PROJECT_NAME}}-agents",
  "includeInReport": [
    "Phase completed",
    "Progress made",
    "Issues encountered"
  ]
}
```

---

## Template Examples

### Minimal Template

```json
{
  "agentId": "agent-{{AGENT_NUMBER}}",
  "priority": "NORMAL",
  "messageType": "NEW_TASK_ASSIGNMENT",
  "timestamp": "{{TIMESTAMP}}",
  "task": {
    "title": "{{TASK_TITLE}}",
    "description": "{{TASK_DESCRIPTION}}",
    "objective": "{{OBJECTIVE}}",
    "context": {
      "projectName": "{{PROJECT_NAME}}"
    },
    "phases": [
      {
        "phase": 1,
        "name": "Execute",
        "tasks": ["Complete task"],
        "deliverable": "{{DELIVERABLE_PATH}}/output.md"
      }
    ],
    "successCriteria": {
      "mustHave": ["Task completed"]
    },
    "technicalRequirements": {},
    "escalation": {
      "blockerThreshold": "30 minutes",
      "escalateTo": "Director",
      "autoEscalateIf": []
    },
    "heartbeat": {
      "frequency": "Every 5 minutes",
      "reportTo": "#{{PROJECT_NAME}}-agents",
      "includeInReport": ["Progress"]
    }
  },
  "metadata": {
    "trackName": "{{TRACK_NAME}}",
    "estimatedHours": "0.5",
    "dependencies": [],
    "outputFormat": "markdown"
  }
}
```

---

## Validation

Validate templates against schema:

```bash
# Install JSON schema validator
npm install -g ajv-cli

# Validate template
ajv validate -s agent-templates/schemas/task-schema.json \
             -d agent-templates/archetypes/research-agent.json
```

---

## Troubleshooting

### Issue: Template variables not replaced

**Solution:** Check deploy script variable replacement logic

### Issue: Invalid JSON syntax

**Solution:** Validate JSON syntax:
```bash
cat template.json | jq .
```

### Issue: Schema validation fails

**Solution:** Validate against schema:
```bash
ajv validate -s schemas/task-schema.json -d archetypes/template.json
```

---

## Next Steps

1. ✅ **Explore Templates**: Review existing templates
2. ✅ **Deploy Agents**: Deploy agents to your project
3. ✅ **Customize**: Create custom agent types
4. ✅ **Share**: Contribute templates to community

---

**For more information, see:**
- [Architecture Documentation](ARCHITECTURE.md)
- [Quick Start Guide](QUICKSTART.md)
- [Troubleshooting Guide](TROUBLESHOOTING.md)

