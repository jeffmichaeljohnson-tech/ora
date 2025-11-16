# Ora Framework - Infrastructure Templates

This directory contains reusable infrastructure templates for rapidly spinning up new Ora project instances with perfect isolation.

## Overview

All infrastructure components are parameterized with `{{PROJECT_NAME}}` to enable multi-project isolation:

- **PostgreSQL**: Schema `ora_{{PROJECT_NAME}}`
- **Pinecone**: Namespace `{{PROJECT_NAME}}`
- **Slack**: Channel `#ora-{{PROJECT_NAME}}-agents`
- **LangSmith**: Project `{{PROJECT_NAME}}`
- **GitHub**: Repository `{{PROJECT_NAME}}`

## Quick Start

Use the master bootstrap script to set up all infrastructure:

```bash
cd infrastructure/bootstrap
./ora-init.sh my-awesome-project
```

This will:
1. ✅ Create PostgreSQL schema
2. ✅ Create Pinecone namespace
3. ✅ Create Slack channel
4. 📋 Guide you through LangSmith setup (manual)
5. 📋 Guide you through GitHub setup (manual)

## Directory Structure

```
infrastructure/
├── postgres/
│   ├── schema-template.sql      # Parameterized PostgreSQL schema
│   └── create-schema.sh          # Schema creation script
├── pinecone/
│   ├── namespace-setup.md        # Namespace strategy documentation
│   └── create-namespace.py       # Namespace creation script
├── slack/
│   └── create-channel.js         # Slack channel creation script
├── langsmith/
│   └── setup-project.md          # LangSmith project setup guide
├── github/
│   └── repo-template.md          # GitHub repository template guide
└── bootstrap/
    ├── ora-init.sh               # Master bootstrap script
    └── cleanup.sh                # Infrastructure cleanup script
```

## Individual Components

### PostgreSQL

**Schema Template**: `postgres/schema-template.sql`
- Parameterized with `{{PROJECT_NAME}}`
- Creates isolated schema: `ora_{{PROJECT_NAME}}`
- Includes: agents, tasks, director_decisions, performance_metrics tables

**Usage**:
```bash
./postgres/create-schema.sh my-project
```

### Pinecone

**Namespace Strategy**: `pinecone/namespace-setup.md`
- Complete documentation on namespace isolation
- Metadata tagging patterns
- Best practices

**Usage**:
```bash
export PINECONE_API_KEY=your-key
python3 pinecone/create-namespace.py my-project
```

### Slack

**Channel Creation**: `slack/create-channel.js`
- Creates channel: `#ora-{{PROJECT_NAME}}-agents`
- Sets topic and purpose
- Requires Node.js and `@slack/web-api`

**Usage**:
```bash
export SLACK_BOT_TOKEN=your-token
node slack/create-channel.js my-project
```

### LangSmith

**Setup Guide**: `langsmith/setup-project.md`
- Manual setup instructions
- Project naming conventions
- Integration examples

### GitHub

**Repository Template**: `github/repo-template.md`
- Repository structure
- Workflow templates
- CI/CD configuration

## Environment Variables

Required for full bootstrap:

```bash
# PostgreSQL
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=postgres
export DB_USER=postgres
export DB_PASSWORD=your-password

# Pinecone
export PINECONE_API_KEY=your-key
export PINECONE_INDEX_NAME=ora-framework-index

# Slack
export SLACK_BOT_TOKEN=your-token

# LangSmith (optional)
export LANGSMITH_API_KEY=your-key
```

## Cleanup

To remove all infrastructure for a project:

```bash
./bootstrap/cleanup.sh my-project --confirm
```

**WARNING**: This will delete PostgreSQL schema and all data. Pinecone namespace cleanup requires manual intervention.

## Best Practices

1. **Consistent Naming**: Use lowercase, hyphenated project names
2. **Isolation**: Each project gets isolated infrastructure
3. **Documentation**: Document all customizations
4. **Backup**: Backup data before cleanup
5. **Testing**: Test infrastructure setup in staging first

## Troubleshooting

### PostgreSQL Schema Creation Fails
- Verify database user has CREATE SCHEMA permissions
- Check database connection settings
- Ensure PostgreSQL is running

### Pinecone Namespace Creation Fails
- Verify API key is set correctly
- Check index name exists
- Ensure Pinecone account has namespace quota

### Slack Channel Creation Fails
- Verify bot token has `channels:write` scope
- Check channel name doesn't already exist
- Ensure Node.js dependencies are installed

## Next Steps

After infrastructure setup:

1. ✅ Configure application environment variables
2. ✅ Initialize agent queue structure
3. ✅ Deploy first agents
4. ✅ Set up monitoring and alerts
5. ✅ Document project-specific configurations

## Support

For issues or questions:
- Check individual component documentation
- Review MCP-WP source implementation
- Consult Ora framework documentation

