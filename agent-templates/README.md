# Ora Agent Templates

**Reusable agent archetypes for rapid deployment in Ora projects**

This library contains standardized agent templates extracted from the MCP-WP autonomous system, enabling you to deploy specialized agents to any Ora project in seconds.

## Quick Start

```bash
# Deploy a research agent
ora-hire-agent my-project research-agent 35 --track "Memory Architecture"

# Deploy an implementation agent
ora-hire-agent my-project implementation-agent 36 --title "Build Feature X"

# Deploy a QA agent
ora-hire-agent my-project qa-agent 37 --track "Testing"
```

## Available Archetypes

### Research Agent
**Purpose:** Deep research on best practices, competitive analysis, and knowledge gathering

**Use Cases:**
- Analyzing best practices for a technology
- Competitive analysis
- Researching implementation patterns
- Creating knowledge catalogs

**Example:**
```bash
ora-hire-agent my-project research-agent 35 \
  --track "Memory Architecture" \
  --title "Research Pinecone Memory Patterns" \
  --description "Research best practices for vector memory architecture"
```

### Implementation Agent
**Purpose:** Build features, write code, create infrastructure

**Use Cases:**
- Implementing new features
- Writing production code
- Creating MCP tools
- Building APIs

**Example:**
```bash
ora-hire-agent my-project implementation-agent 36 \
  --track "Core Features" \
  --title "Build WordPress Core Tool" \
  --description "Implement MCP tool for WordPress core analysis"
```

### QA Agent
**Purpose:** Test deliverables, validate quality, ensure standards

**Use Cases:**
- Testing implementations
- Validating quality standards
- Running test suites
- Creating quality reports

**Example:**
```bash
ora-hire-agent my-project qa-agent 37 \
  --track "Testing" \
  --title "Test Feature X" \
  --description "Comprehensive testing of Feature X implementation"
```

### Documentation Agent
**Purpose:** Write guides, create tutorials, maintain knowledge base

**Use Cases:**
- Writing user guides
- Creating API documentation
- Writing tutorials
- Maintaining README files

**Example:**
```bash
ora-hire-agent my-project documentation-agent 38 \
  --track "Documentation" \
  --title "Create User Guide" \
  --description "Write comprehensive user guide for Feature X"
```

### Infrastructure Agent
**Purpose:** Set up services, configure environments, optimize performance

**Use Cases:**
- Setting up PostgreSQL schemas
- Configuring Pinecone namespaces
- Creating Slack channels
- Setting up LangSmith projects

**Example:**
```bash
ora-hire-agent my-project infrastructure-agent 39 \
  --track "Infrastructure" \
  --title "Setup Project Infrastructure" \
  --description "Configure all infrastructure services for new project"
```

## Template Structure

All templates follow a standardized structure:

```
agent-templates/
├── archetypes/              # Agent archetype templates
│   ├── research-agent.json
│   ├── implementation-agent.json
│   ├── qa-agent.json
│   ├── documentation-agent.json
│   └── infrastructure-agent.json
├── schemas/                 # JSON schemas for validation
│   ├── task-schema.json
│   ├── heartbeat-schema.json
│   └── communication-standard.json
└── deploy/                  # Deployment automation
    └── ora-hire-agent.sh
```

## Template Variables

Templates use the following variables that are automatically replaced:

- `{{PROJECT_NAME}}` - Project name (e.g., "Ora", "my-project")
- `{{TRACK_NAME}}` - Track or feature area name
- `{{AGENT_NUMBER}}` - Agent number (e.g., 35)
- `{{TIMESTAMP}}` - ISO 8601 timestamp
- `{{TASK_TITLE}}` - Task title
- `{{TASK_DESCRIPTION}}` - Task description
- `{{OUTPUT_LOCATION}}` - Path for deliverables
- `{{TIMELINE}}` - Expected timeline

## Communication Schema

All agents follow the standardized communication schema defined in `schemas/communication-standard.json`:

- **File-based messaging** via `agents/_queue/` directory
- **Outbox** for agent messages to director
- **Inbox** for director tasks to agents
- **Slack integration** for real-time updates
- **Heartbeat** reporting every 5 minutes

## Deployment Process

When you run `ora-hire-agent`, it:

1. ✅ Validates archetype and arguments
2. ✅ Creates project directory structure
3. ✅ Generates task file from template
4. ✅ Creates agent configuration
5. ✅ Sets up workflow helpers
6. ✅ Configures communication system

The agent is immediately ready to read its task and begin work.

## Customization

### Creating Custom Archetypes

1. Copy an existing archetype template:
   ```bash
   cp archetypes/research-agent.json archetypes/my-custom-agent.json
   ```

2. Modify the template with your specific requirements

3. Use it with `ora-hire-agent`:
   ```bash
   ora-hire-agent my-project my-custom-agent 40
   ```

### Modifying Templates

Templates are JSON files with variable placeholders. Edit them directly to customize:

- Phase structure
- Success criteria
- Technical requirements
- Escalation procedures

## Validation

All task files are validated against `schemas/task-schema.json`:

```bash
# Validate a task file
ajv validate -s schemas/task-schema.json -d path/to/task.json
```

## Best Practices

1. **Use appropriate archetypes** - Match the agent type to the task
2. **Set clear objectives** - Provide detailed task descriptions
3. **Define success criteria** - Be specific about what "done" means
4. **Set realistic timelines** - Account for complexity
5. **Monitor progress** - Check Slack channel regularly

## Examples

### Complete Workflow

```bash
# 1. Deploy research agent
ora-hire-agent my-project research-agent 35 \
  --track "Feature Research" \
  --title "Research Best Practices" \
  --timeline "2 hours"

# 2. Wait for research completion, then deploy implementation
ora-hire-agent my-project implementation-agent 36 \
  --track "Feature Implementation" \
  --title "Build Feature Based on Research" \
  --timeline "4 hours"

# 3. Deploy QA agent
ora-hire-agent my-project qa-agent 37 \
  --track "Testing" \
  --title "Test Feature Implementation" \
  --timeline "1 hour"
```

## Integration with Ora Framework

Agent templates integrate seamlessly with Ora framework:

- **Unified Memory** - Agents use Pinecone for context
- **PostgreSQL State** - Agent state persisted in database
- **Slack Updates** - Real-time progress in `#{PROJECT_NAME}-agents`
- **File-based Coordination** - Reliable agent communication

## Support

For issues or questions:
1. Check `schemas/communication-standard.json` for communication patterns
2. Review existing agent implementations in MCP-WP
3. Validate task files against schemas
4. Check Slack channel for agent updates

## License

Part of the Ora framework. See main project LICENSE file.

