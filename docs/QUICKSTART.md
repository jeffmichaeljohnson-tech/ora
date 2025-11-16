# Ora Framework - Quick Start Guide

**Get your first autonomous project running in 10 minutes.**

---

## Prerequisites

Before you begin, make sure you have:

### Required Accounts & API Keys

1. **PostgreSQL Database**
   - Local PostgreSQL installation, OR
   - Remote PostgreSQL instance (AWS RDS, Heroku, etc.)
   - Database credentials (host, port, database name, user, password)

2. **Pinecone Account**
   - Sign up at [pinecone.io](https://www.pinecone.io)
   - Create an index (or use existing)
   - Get your API key from the dashboard
   - Note your index name

3. **Slack Workspace**
   - Access to a Slack workspace
   - Create a Slack app at [api.slack.com/apps](https://api.slack.com/apps)
   - Get a bot token with `channels:write` and `channels:manage` scopes

4. **LangSmith Account** (Optional but recommended)
   - Sign up at [smith.langchain.com](https://smith.langchain.com)
   - Get your API key

5. **GitHub Account** (Optional)
   - Personal access token with repo creation permissions

### Required Software

- **Node.js** (v14+)
- **Python 3** (v3.8+)
- **PostgreSQL Client** (`psql` command)
- **Git**
- **Bash** (macOS/Linux) or **WSL** (Windows)

---

## Step 1: Clone and Setup (2 minutes)

```bash
# Clone the repository
git clone https://github.com/your-org/ora.git
cd ora

# Install Node.js dependencies (for Slack script)
cd infrastructure/slack
npm install @slack/web-api
cd ../..

# Install Python dependencies (for Pinecone script)
pip3 install pinecone-client
```

---

## Step 2: Configure Environment Variables (1 minute)

Create a `.env` file or export variables:

```bash
# PostgreSQL Configuration
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=postgres
export DB_USER=postgres
export DB_PASSWORD=your-password

# Pinecone Configuration
export PINECONE_API_KEY=your-pinecone-api-key
export PINECONE_INDEX_NAME=ora-framework-index

# Slack Configuration
export SLACK_BOT_TOKEN=xoxb-your-slack-bot-token

# LangSmith (Optional)
export LANGSMITH_API_KEY=your-langsmith-key
```

**Tip:** Add these to your `~/.bashrc` or `~/.zshrc` to persist them.

---

## Step 3: Create Your First Project (3 minutes)

```bash
# Navigate to bootstrap directory
cd infrastructure/bootstrap

# Run ora-init with your project name
./ora-init.sh my-first-project
```

**What happens:**
1. ✅ Creates PostgreSQL schema: `ora_my-first-project`
2. ✅ Creates Pinecone namespace: `my-first-project`
3. ✅ Creates Slack channel: `#ora-my-first-project-agents`
4. 📋 Shows instructions for LangSmith setup (manual)
5. 📋 Shows instructions for GitHub setup (manual)

**Expected Output:**
```
================================================================================
  ORA FRAMEWORK - INFRASTRUCTURE BOOTSTRAP
================================================================================

Project: my-first-project
Mode: Normal

▶ Setting up PostgreSQL schema...
✅ PostgreSQL schema created: ora_my-first-project

▶ Setting up Pinecone namespace...
✅ Pinecone namespace created: my-first-project

▶ Setting up Slack channel...
✅ Slack channel created: #ora-my-first-project-agents

================================================================================
  SETUP SUMMARY
================================================================================

✅ Infrastructure bootstrap completed successfully!
```

---

## Step 4: Manual Setup Steps (3 minutes)

### LangSmith Project Setup

1. Go to [smith.langchain.com/projects](https://smith.langchain.com/projects)
2. Click "Create Project"
3. Name: `my-first-project`
4. Description: `Ora Framework - my-first-project autonomous agent system`
5. Click "Create"

### GitHub Repository Setup (Optional)

1. Go to [github.com/new](https://github.com/new)
2. Repository name: `my-first-project`
3. Description: `Ora Framework - my-first-project autonomous agent system`
4. Choose public or private
5. Click "Create repository"

---

## Step 5: Deploy Your First Agents (2 minutes)

```bash
# Navigate to agent templates
cd ../../agent-templates/deploy

# Deploy a research agent
./ora-hire-agent.sh research-agent my-first-project

# Deploy an implementation agent
./ora-hire-agent.sh implementation-agent my-first-project

# Deploy a QA agent
./ora-hire-agent.sh qa-agent my-first-project
```

**What happens:**
- Creates agent directory structure
- Copies agent template
- Configures project-specific settings
- Sets up inbox/outbox directories
- Agent is ready to receive tasks!

---

## Step 6: Verify Everything Works

### Check PostgreSQL Schema

```bash
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\dn ora_*"
```

You should see: `ora_my-first-project`

### Check Pinecone Namespace

```bash
python3 -c "
from pinecone import Pinecone
pc = Pinecone(api_key='$PINECONE_API_KEY')
index = pc.Index('$PINECONE_INDEX_NAME')
stats = index.describe_index_stats()
print(stats)
"
```

You should see your namespace in the stats.

### Check Slack Channel

1. Open Slack
2. Look for channel: `#ora-my-first-project-agents`
3. Channel should exist and be ready for messages

---

## Step 7: Create Your First Task

```bash
# Navigate to your project's agent queue
cd /Users/computer/ora/projects/my-first-project/agents/_queue

# Create a task file
cat > inbox/task-001.json << 'EOF'
{
  "agentId": "agent-1",
  "priority": "HIGH",
  "messageType": "NEW_TASK_ASSIGNMENT",
  "timestamp": "2025-01-16T00:00:00Z",
  "task": {
    "title": "Research Best Practices",
    "description": "Research best practices for autonomous agent systems",
    "objective": "Create a comprehensive research document",
    "context": {
      "projectName": "my-first-project"
    },
    "phases": [
      {
        "phase": 1,
        "name": "Research",
        "tasks": ["Research topic", "Document findings"],
        "deliverable": "docs/research.md"
      }
    ]
  }
}
EOF
```

---

## Next Steps

### Monitor Your Agents

1. **Slack**: Watch `#ora-my-first-project-agents` for agent updates
2. **PostgreSQL**: Query agent status:
   ```sql
   SELECT * FROM ora_my-first-project.agents;
   ```
3. **File System**: Check `outbox/` for agent outputs

### Deploy More Agents

```bash
# Available agent types:
./ora-hire-agent.sh research-agent my-first-project
./ora-hire-agent.sh implementation-agent my-first-project
./ora-hire-agent.sh qa-agent my-first-project
./ora-hire-agent.sh documentation-agent my-first-project
./ora-hire-agent.sh infrastructure-agent my-first-project
```

### Customize Your Project

- Edit agent templates in `agent-templates/archetypes/`
- Configure project-specific settings
- Add custom agent types
- Integrate additional tools

---

## Troubleshooting

### Issue: PostgreSQL Connection Failed

**Solution:**
- Verify PostgreSQL is running: `pg_isready`
- Check credentials: `psql -h $DB_HOST -U $DB_USER -d $DB_NAME`
- Ensure user has CREATE SCHEMA permissions

### Issue: Pinecone API Error

**Solution:**
- Verify API key: `echo $PINECONE_API_KEY`
- Check index exists: `pinecone list-indexes`
- Verify index name matches `PINECONE_INDEX_NAME`

### Issue: Slack Channel Creation Failed

**Solution:**
- Verify bot token: `echo $SLACK_BOT_TOKEN`
- Check bot has `channels:write` scope
- Ensure channel name doesn't already exist

### Issue: Agent Not Responding

**Solution:**
- Check task file format (valid JSON)
- Verify agent directory exists
- Check agent has read permissions
- Review agent logs in `logs/` directory

---

## Getting Help

- 📖 **Full Documentation**: See `/docs` directory
- 💬 **Slack**: Join `#ora-agents` for community support
- 🐛 **Issues**: Check `docs/TROUBLESHOOTING.md`
- 📧 **Email**: support@ora.dev

---

## What's Next?

Now that you have Ora running:

1. ✅ **Read Architecture Docs**: Understand how Ora works
2. ✅ **Explore Agent Templates**: Customize agents for your needs
3. ✅ **Create Custom Agents**: Build agents specific to your project
4. ✅ **Integrate Tools**: Add GitHub, LangSmith, and more
5. ✅ **Scale Up**: Create multiple projects with perfect isolation

---

**Congratulations! You've set up your first Ora project! 🎉**

Your autonomous workforce is ready to start building.

