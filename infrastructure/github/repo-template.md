# GitHub Repository Template for Ora Framework

## Overview

Each Ora project should have its own GitHub repository for version control, CI/CD, and collaboration. This guide outlines the repository structure and setup.

## Naming Convention

- **Repository Format**: `{project-name}` (lowercase, hyphenated)
- **Example**: Project `my-awesome-app` → Repository `my-awesome-app`
- **Description**: "Ora Framework - {project-name} autonomous agent system"

## Repository Structure

```
{project-name}/
├── .github/
│   └── workflows/
│       ├── autonomous-director.yml    # Daily director sessions
│       ├── agent-workflow.yml          # Agent task processing
│       └── langsmith-monitor.yml       # LangSmith integration
├── agents/
│   ├── _queue/
│   │   ├── inbox/                      # New tasks
│   │   ├── outbox/                     # Assigned tasks
│   │   └── processed/                  # Completed tasks
│   └── [agent-directories]/            # Agent-specific code
├── infrastructure/                     # Infrastructure templates
├── core/                               # Core framework code
├── docs/                               # Documentation
├── scripts/                            # Utility scripts
├── .env.example                        # Environment variable template
├── .gitignore                          # Git ignore rules
├── README.md                           # Project README
├── requirements.txt                    # Python dependencies
└── database_schema.sql                 # PostgreSQL schema
```

## Setup Steps

### 1. Create Repository

**Via GitHub Web UI:**
1. Navigate to: https://github.com/new
2. Repository name: `{project-name}`
3. Description: `Ora Framework - {project-name} autonomous agent system`
4. Visibility: Private (recommended) or Public
5. Initialize with README: ✅
6. Add .gitignore: Python
7. Choose license: MIT (or your preference)
8. Click "Create repository"

**Via GitHub CLI:**
```bash
gh repo create {project-name} \
  --description "Ora Framework - {project-name} autonomous agent system" \
  --private \
  --clone
```

### 2. Clone and Initialize

```bash
git clone https://github.com/your-org/{project-name}.git
cd {project-name}
```

### 3. Copy Template Files

Copy from Ora framework template:

```bash
# Copy workflow templates
mkdir -p .github/workflows
cp /path/to/ora/infrastructure/github/workflows/* .github/workflows/

# Copy agent structure
cp -r /path/to/ora/agent-templates/* agents/

# Copy core framework
cp -r /path/to/ora/core/* core/
```

### 4. Configure Workflows

Update workflow files with project-specific values:

**`.github/workflows/autonomous-director.yml`:**
```yaml
env:
  LANGSMITH_PROJECT: {project-name}  # Update this
  POSTGRES_SCHEMA: ora_{project-name}  # Update this
```

**`.github/workflows/agent-workflow.yml`:**
```yaml
env:
  PROJECT_NAME: {project-name}  # Update this
  SLACK_CHANNEL: ora-{project-name}-agents  # Update this
```

### 5. Set Repository Secrets

Navigate to: `Settings → Secrets and variables → Actions`

Add required secrets:
- `ANTHROPIC_API_KEY` - Claude API access
- `LANGSMITH_API_KEY` - LangSmith tracing
- `PINECONE_API_KEY` - Pinecone vector DB
- `OPENAI_API_KEY` - OpenAI embeddings
- `GH_ACCESS_TOKEN` - GitHub operations
- `SLACK_BOT_TOKEN` - Slack notifications
- `POSTGRES_URI` - PostgreSQL connection string

### 6. Configure Branch Protection

1. Navigate to: `Settings → Branches`
2. Add rule for `main` branch:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass
   - ✅ Require conversation resolution
   - ✅ Include administrators

### 7. Set Up Webhooks (Optional)

For Slack notifications:
1. Navigate to: `Settings → Webhooks`
2. Add webhook:
   - Payload URL: Slack webhook URL
   - Content type: `application/json`
   - Events: Pull requests, pushes, issues

## Workflow Templates

### Autonomous Director Workflow

Runs daily director sessions:

```yaml
name: Autonomous Director Session

on:
  schedule:
    - cron: '0 9 * * *'  # 9 AM UTC daily
  workflow_dispatch:

jobs:
  director-session:
    runs-on: ubuntu-latest
    # ... (see template)
```

### Agent Workflow

Processes agent tasks:

```yaml
name: Agent Task Processing

on:
  workflow_dispatch:
    inputs:
      agent_id:
        description: 'Agent ID to process'
        required: true

jobs:
  agent-task:
    runs-on: ubuntu-latest
    # ... (see template)
```

## Best Practices

1. **One Repository Per Project**
   - Isolated version control
   - Independent CI/CD

2. **Consistent Naming**
   - Repository name matches project name
   - Matches PostgreSQL schema and Pinecone namespace

3. **Protect Main Branch**
   - Require PR reviews
   - Enforce status checks

4. **Use Secrets**
   - Never commit API keys
   - Use GitHub Secrets

5. **Document Everything**
   - Clear README
   - Agent documentation
   - Architecture diagrams

## Integration with Ora Framework

### Environment Variables

Set in repository secrets and local `.env`:

```bash
PROJECT_NAME={project-name}
POSTGRES_SCHEMA=ora_{project-name}
PINECONE_NAMESPACE={project-name}
SLACK_CHANNEL=ora-{project-name}-agents
LANGSMITH_PROJECT={project-name}
```

### Agent Queue Structure

```
agents/_queue/
├── inbox/          # New tasks (JSON files)
├── outbox/         # Assigned tasks
└── processed/      # Completed tasks
```

### CI/CD Pipeline

1. **On Push to Main**
   - Run tests
   - Deploy to staging

2. **On PR**
   - Run tests
   - Check code quality

3. **Scheduled**
   - Daily director sessions
   - Health checks

## Troubleshooting

### Workflow Failures
- **Cause**: Missing secrets or incorrect configuration
- **Solution**: Verify all secrets are set, check workflow syntax

### Permission Errors
- **Cause**: Token lacks required permissions
- **Solution**: Regenerate token with correct scopes

### Branch Protection Issues
- **Cause**: Status checks not passing
- **Solution**: Fix failing checks, verify workflow configuration

## Next Steps

After repository setup:

1. ✅ Clone repository locally
2. ✅ Copy template files
3. ✅ Configure workflows
4. ✅ Set repository secrets
5. ✅ Initialize agent queue structure
6. ✅ Create first agent task

