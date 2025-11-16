# LangSmith Project Setup Guide for Ora Framework

## Overview

LangSmith provides observability, debugging, and evaluation for LangChain applications. Each Ora project should have its own LangSmith project for isolated trace collection and analysis.

## Naming Convention

- **Project Format**: `{project-name}` (lowercase, hyphenated)
- **Example**: Project `my-awesome-app` → LangSmith Project `my-awesome-app`
- **Description**: "Ora Framework - {project-name} autonomous agent system"

## Prerequisites

1. **LangSmith Account**
   - Sign up at https://smith.langchain.com
   - Create organization (if team setup)

2. **API Key**
   - Navigate to: https://smith.langchain.com/settings
   - Generate API key
   - Set environment variable: `LANGSMITH_API_KEY`

3. **Required Secrets** (for cloud execution)
   - `ANTHROPIC_API_KEY` - Claude API access
   - `GITHUB_TOKEN` - GitHub integration
   - `PINECONE_API_KEY` - Pinecone access
   - Add at: https://smith.langchain.com/settings/secrets

## Manual Setup Steps

### 1. Create Project

1. Navigate to: https://smith.langchain.com/projects
2. Click "Create Project"
3. Fill in:
   - **Name**: `{project-name}` (e.g., `my-awesome-app`)
   - **Description**: `Ora Framework - {project-name} autonomous agent system`
   - **Organization**: Select your organization
4. Click "Create"

### 2. Configure Project Settings

1. Open project settings
2. Set default environment: `production`
3. Enable:
   - ✅ Trace collection
   - ✅ Dataset evaluation
   - ✅ Prompt playground

### 3. Add API Secrets

1. Navigate to: https://smith.langchain.com/settings/secrets
2. Add required secrets (see Prerequisites)

### 4. Configure Environment Variables

Set these in your application:

```bash
export LANGSMITH_API_KEY="your-api-key"
export LANGSMITH_PROJECT="{project-name}"
export LANGSMITH_TRACING=true
```

## Programmatic Setup (Python)

```python
from langsmith import Client

client = Client(api_key=os.getenv("LANGSMITH_API_KEY"))

# Create project
project = client.create_project(
    project_name="my-awesome-app",
    description="Ora Framework - my-awesome-app autonomous agent system",
    project_extra={
        "framework": "ora",
        "type": "autonomous-agents"
    }
)

print(f"Project created: {project['name']}")
```

## Integration with Ora Framework

### 1. Update Agent Code

Add LangSmith tracing to agent execution:

```python
from langsmith import traceable

@traceable(name="agent-execution", project_name="{project-name}")
def execute_agent_task(agent_id, task):
    # Agent logic here
    pass
```

### 2. Configure LangGraph

If using LangGraph, set project in config:

```python
from langgraph.checkpoint.langchain import LangChainCheckpointSaver
from langsmith import Client

client = Client()
checkpointer = LangChainCheckpointSaver(
    client=client,
    project_name="{project-name}"
)
```

### 3. Environment Variables

Add to `.env` file:

```bash
LANGSMITH_API_KEY=your-key-here
LANGSMITH_PROJECT={project-name}
LANGSMITH_TRACING=true
```

## Project Structure

Each LangSmith project will contain:

- **Traces**: All agent execution traces
- **Runs**: Individual agent runs
- **Datasets**: Evaluation datasets
- **Prompts**: Prompt templates and versions
- **Feedback**: Human feedback on agent outputs

## Best Practices

1. **One Project Per Ora Instance**
   - Isolate traces per project
   - Easier debugging and analysis

2. **Consistent Naming**
   - Use project name as LangSmith project name
   - Matches PostgreSQL schema and Pinecone namespace

3. **Enable Tracing Early**
   - Set up tracing from day one
   - Capture all agent decisions

4. **Use Datasets**
   - Create evaluation datasets
   - Test agent improvements

5. **Monitor Performance**
   - Set up alerts for errors
   - Track token usage

## Troubleshooting

### Project Not Found
- **Cause**: Project name mismatch or doesn't exist
- **Solution**: Verify project name, create if missing

### Traces Not Appearing
- **Cause**: API key not set or incorrect
- **Solution**: Verify `LANGSMITH_API_KEY` environment variable

### Permission Errors
- **Cause**: API key lacks permissions
- **Solution**: Regenerate API key with correct permissions

## API Reference

- LangSmith Python SDK: https://python.langchain.com/docs/langsmith
- LangSmith API Docs: https://docs.smith.langchain.com

## Next Steps

After setting up LangSmith project:

1. ✅ Configure agent code to use project name
2. ✅ Set environment variables
3. ✅ Test trace collection
4. ✅ Set up monitoring dashboards
5. ✅ Create evaluation datasets

