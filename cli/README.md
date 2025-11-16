# Ora Framework CLI

Command-line tools for managing Ora Framework projects.

## Installation

Add the CLI directory to your PATH:

```bash
export PATH="/Users/computer/ora/cli:$PATH"
```

Or create symlinks:

```bash
ln -s /Users/computer/ora/cli/ora-init /usr/local/bin/ora-init
ln -s /Users/computer/ora/cli/ora-status /usr/local/bin/ora-status
ln -s /Users/computer/ora/cli/ora-destroy /usr/local/bin/ora-destroy
```

## Commands

### `ora-init`

Initialize a new Ora Framework project.

**Usage:**
```bash
ora-init <project-name> [options]
```

**Options:**
- `--skip-interactive` - Skip interactive prompts
- `--dry-run` - Show what would be done without executing
- `--help` - Show help message

**Examples:**
```bash
ora-init my-awesome-project
ora-init test-project-alpha --skip-interactive
ora-init demo-app --dry-run
```

**What it does:**
1. Creates PostgreSQL schema: `ora_<project-name>`
2. Creates Pinecone namespace: `<project-name>`
3. Creates Slack channel: `#ora-<project-name>-agents`
4. Sets up LangSmith project: `<project-name>`
5. Creates GitHub repository: `<project-name>`
6. Deploys 3-5 standard agents
7. Initializes project directory structure

### `ora-status`

Check the status of an Ora Framework project.

**Usage:**
```bash
ora-status <project-name>
```

**Examples:**
```bash
ora-status my-awesome-project
ora-status test-project-alpha
```

**What it checks:**
- PostgreSQL schema existence
- Pinecone namespace existence
- Slack channel existence
- Project directory structure
- Git repository status

### `ora-destroy`

Safely remove an Ora Framework project and its resources.

**Usage:**
```bash
ora-destroy <project-name> [--confirm]
```

**Examples:**
```bash
ora-destroy my-awesome-project
ora-destroy test-project-alpha --confirm
```

**Warning:** This permanently deletes:
- PostgreSQL schema
- Project directory
- GitHub repository (if local clone exists)

**Note:** Manual cleanup required for:
- Pinecone namespace
- Slack channel
- LangSmith project

## Prerequisites

### Required Environment Variables

```bash
# PostgreSQL
export DB_HOST="localhost"
export DB_PORT="5432"
export DB_NAME="postgres"
export DB_USER="postgres"
export DB_PASSWORD="your-password"
# OR
export POSTGRES_URI="postgresql://user:password@host:port/database"

# Pinecone
export PINECONE_API_KEY="your-api-key"
export PINECONE_INDEX_NAME="ora-framework-index"  # Optional, defaults to ora-framework-index

# Slack
export SLACK_BOT_TOKEN="xoxb-your-token"
export SLACK_CHANNEL_PREFIX="ora"  # Optional, defaults to ora

# LangSmith
export LANGSMITH_API_KEY="your-api-key"

# GitHub
export GITHUB_TOKEN="your-personal-access-token"
```

### Required Commands

- `psql` - PostgreSQL client
- `python3` - Python 3 interpreter
- `node` - Node.js runtime
- `gh` - GitHub CLI

Install missing tools:

```bash
# PostgreSQL client (macOS)
brew install postgresql

# Node.js (macOS)
brew install node

# GitHub CLI (macOS)
brew install gh
```

## Project Structure

After running `ora-init`, your project will have this structure:

```
<project-name>/
├── agents/
│   ├── _queue/
│   │   ├── inbox/          # New tasks
│   │   ├── outbox/         # Assigned tasks
│   │   └── processed/      # Completed tasks
│   ├── research-agent/
│   ├── implementation-agent/
│   ├── qa-agent/
│   ├── documentation-agent/
│   └── infrastructure-agent/
├── infrastructure/         # Infrastructure templates
├── core/                   # Core framework code
├── docs/                   # Documentation
├── scripts/                # Utility scripts
└── README.md              # Project README
```

## Troubleshooting

### "Missing required environment variables"

Set all required environment variables before running commands. See Prerequisites section.

### "Missing required commands"

Install missing tools. See Prerequisites section.

### "PostgreSQL schema creation failed"

- Check PostgreSQL is running
- Verify connection credentials
- Ensure user has CREATE SCHEMA permissions

### "Pinecone namespace creation failed"

- Verify PINECONE_API_KEY is set
- Check PINECONE_INDEX_NAME exists
- Ensure API key has proper permissions

### "Slack channel creation failed"

- Verify SLACK_BOT_TOKEN is set
- Check bot has channels:write scope
- Ensure bot is added to workspace

### "GitHub repository creation failed"

- Verify GITHUB_TOKEN is set
- Check GitHub CLI is authenticated (`gh auth login`)
- Ensure token has repo creation permissions

## Library Functions

The CLI uses library functions in `lib/`:

- `validate-project-name.sh` - Project name validation
- `progress-indicator.sh` - Progress display utilities
- `rollback-cleanup.sh` - Rollback and cleanup on failure

## Integration

The CLI integrates with:

- **PostgreSQL** - Schema creation via `infrastructure/postgres/create-schema.sh`
- **Pinecone** - Namespace creation via `infrastructure/pinecone/create-namespace.py`
- **Slack** - Channel creation via `infrastructure/slack/create-channel.js`
- **LangSmith** - Manual setup (see `infrastructure/langsmith/setup-project.md`)
- **GitHub** - Repository creation via GitHub CLI
- **Agent Templates** - Agent deployment via `agent-templates/archetypes/`

## Support

For issues or questions:
1. Check troubleshooting section
2. Review infrastructure setup guides
3. Check project logs in `agents/_queue/logs/`

