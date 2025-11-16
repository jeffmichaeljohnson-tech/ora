# Ora Framework - Troubleshooting Guide

**Common issues and solutions for Ora framework setup and operation.**

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Infrastructure Setup](#infrastructure-setup)
3. [Agent Problems](#agent-problems)
4. [Memory System Issues](#memory-system-issues)
5. [Communication Problems](#communication-problems)
6. [Performance Issues](#performance-issues)

---

## Installation Issues

### Issue: `ora-init.sh` script not executable

**Symptoms:**
```bash
bash: ./ora-init.sh: Permission denied
```

**Solution:**
```bash
chmod +x infrastructure/bootstrap/ora-init.sh
```

---

### Issue: Python dependencies missing

**Symptoms:**
```bash
ModuleNotFoundError: No module named 'pinecone'
```

**Solution:**
```bash
pip3 install pinecone-client
# Or
pip3 install -r requirements.txt
```

---

### Issue: Node.js dependencies missing

**Symptoms:**
```bash
Error: Cannot find module '@slack/web-api'
```

**Solution:**
```bash
cd infrastructure/slack
npm install @slack/web-api
```

---

## Infrastructure Setup

### Issue: PostgreSQL connection failed

**Symptoms:**
```bash
❌ Failed to create schema
psql: connection to server failed
```

**Diagnosis:**
1. Check if PostgreSQL is running:
   ```bash
   pg_isready
   ```

2. Test connection manually:
   ```bash
   psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME
   ```

3. Check credentials:
   ```bash
   echo $DB_HOST $DB_PORT $DB_NAME $DB_USER
   ```

**Solutions:**

**Solution 1: PostgreSQL not running**
```bash
# macOS
brew services start postgresql

# Linux
sudo systemctl start postgresql

# Docker
docker start postgres-container
```

**Solution 2: Wrong credentials**
```bash
# Verify and update
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=postgres
export DB_USER=postgres
export DB_PASSWORD=your-password
```

**Solution 3: User lacks CREATE SCHEMA permission**
```sql
-- Grant permission
GRANT CREATE ON DATABASE your_database TO your_user;

-- Or use superuser
export DB_USER=postgres
```

---

### Issue: Pinecone API error

**Symptoms:**
```bash
❌ Pinecone API error: Invalid API key
```

**Diagnosis:**
1. Check API key:
   ```bash
   echo $PINECONE_API_KEY
   ```

2. Verify index exists:
   ```bash
   python3 -c "
   from pinecone import Pinecone
   pc = Pinecone(api_key='$PINECONE_API_KEY')
   print(pc.list_indexes())
   "
   ```

**Solutions:**

**Solution 1: Invalid API key**
```bash
# Get new API key from pinecone.io dashboard
export PINECONE_API_KEY=your-new-key
```

**Solution 2: Index doesn't exist**
```bash
# Create index first
python3 -c "
from pinecone import Pinecone, ServerlessSpec
pc = Pinecone(api_key='$PINECONE_API_KEY')
pc.create_index(
    name='ora-framework-index',
    dimension=1536,
    metric='cosine',
    spec=ServerlessSpec(cloud='aws', region='us-east-1')
)
"
```

**Solution 3: Wrong index name**
```bash
# List existing indexes
python3 -c "
from pinecone import Pinecone
pc = Pinecone(api_key='$PINECONE_API_KEY')
print(pc.list_indexes())
"

# Update index name
export PINECONE_INDEX_NAME=your-actual-index-name
```

---

### Issue: Slack channel creation failed

**Symptoms:**
```bash
❌ Failed to create channel: invalid_auth
```

**Diagnosis:**
1. Check bot token:
   ```bash
   echo $SLACK_BOT_TOKEN
   ```

2. Verify bot scopes:
   - Go to [api.slack.com/apps](https://api.slack.com/apps)
   - Check OAuth & Permissions
   - Ensure `channels:write` and `channels:manage` scopes

**Solutions:**

**Solution 1: Invalid bot token**
```bash
# Get new token from Slack app settings
export SLACK_BOT_TOKEN=xoxb-your-new-token
```

**Solution 2: Missing scopes**
1. Go to [api.slack.com/apps](https://api.slack.com/apps)
2. Select your app
3. Go to "OAuth & Permissions"
4. Add scopes: `channels:write`, `channels:manage`
5. Reinstall app to workspace
6. Get new token

**Solution 3: Channel already exists**
```bash
# Check existing channels
# Or use --force flag (if script supports it)
# Or choose different project name
```

---

## Agent Problems

### Issue: Agent not responding to tasks

**Symptoms:**
- Task files in `inbox/` not being processed
- No output files in `outbox/`
- Agent appears inactive

**Diagnosis:**
1. Check agent directory exists:
   ```bash
   ls -la projects/my-project/agents/_queue/
   ```

2. Check task file format:
   ```bash
   cat projects/my-project/agents/_queue/inbox/task-*.json | jq .
   ```

3. Check agent logs:
   ```bash
   tail -f projects/my-project/agents/_queue/logs/agent-*.log
   ```

**Solutions:**

**Solution 1: Invalid task JSON**
```bash
# Validate JSON
cat task.json | jq .

# Fix syntax errors
# Ensure all required fields present
```

**Solution 2: Agent process not running**
```bash
# Check if agent process exists
ps aux | grep agent

# Start agent (if using process-based agents)
# Or ensure file watcher is running
```

**Solution 3: Permission issues**
```bash
# Check file permissions
ls -la projects/my-project/agents/_queue/inbox/

# Fix permissions
chmod 644 projects/my-project/agents/_queue/inbox/*.json
chmod 755 projects/my-project/agents/_queue/
```

---

### Issue: Agent creating invalid output

**Symptoms:**
- Output files in `outbox/` are malformed
- Director can't parse agent outputs
- Tasks stuck in processing

**Diagnosis:**
1. Check output file format:
   ```bash
   cat projects/my-project/agents/_queue/outbox/msg-*.json | jq .
   ```

2. Check agent template:
   ```bash
   cat agent-templates/archetypes/your-agent-type.json | jq .
   ```

**Solutions:**

**Solution 1: Fix agent template**
- Ensure template follows schema
- Validate against `agent-templates/schemas/task-schema.json`
- Fix any syntax errors

**Solution 2: Update agent code**
- Check agent implementation
- Ensure it follows output schema
- Test with sample task

---

## Memory System Issues

### Issue: Pinecone queries returning no results

**Symptoms:**
- Vector queries return empty results
- Agents can't find relevant context
- Memory appears empty

**Diagnosis:**
1. Check namespace:
   ```bash
   python3 -c "
   from pinecone import Pinecone
   pc = Pinecone(api_key='$PINECONE_API_KEY')
   index = pc.Index('$PINECONE_INDEX_NAME')
   stats = index.describe_index_stats()
   print(stats)
   "
   ```

2. Check if vectors exist:
   ```python
   # Query with metadata filter
   results = index.query(
       vector=query_vector,
       top_k=10,
       namespace="my-project",
       filter={"project": "my-project"}
   )
   print(results)
   ```

**Solutions:**

**Solution 1: No vectors in namespace**
- Ensure vectors are being created
- Check vector creation code
- Verify namespace name matches

**Solution 2: Wrong namespace**
```bash
# List all namespaces
python3 -c "
from pinecone import Pinecone
pc = Pinecone(api_key='$PINECONE_API_KEY')
index = pc.Index('$PINECONE_INDEX_NAME')
stats = index.describe_index_stats()
print(stats.namespaces)
"
```

**Solution 3: Metadata filter too strict**
- Relax metadata filters
- Check metadata tags on vectors
- Ensure project metadata is set

---

### Issue: PostgreSQL queries failing

**Symptoms:**
- Can't query agent status
- Schema not found errors
- Connection errors

**Diagnosis:**
1. Check schema exists:
   ```sql
   SELECT schema_name 
   FROM information_schema.schemata 
   WHERE schema_name LIKE 'ora_%';
   ```

2. Test connection:
   ```bash
   psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "\dn"
   ```

**Solutions:**

**Solution 1: Schema doesn't exist**
```bash
# Recreate schema
./infrastructure/postgres/create-schema.sh my-project
```

**Solution 2: Wrong schema name**
```bash
# Check actual schema name
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "\dn ora_*"

# Update project configuration
export POSTGRES_SCHEMA=ora_actual-project-name
```

**Solution 3: Connection issues**
- Check database credentials
- Verify network connectivity
- Check firewall rules

---

## Communication Problems

### Issue: Tasks not being picked up

**Symptoms:**
- Tasks in `inbox/` not processed
- No agent activity
- Tasks accumulating

**Diagnosis:**
1. Check file watcher (if using):
   ```bash
   ps aux | grep file-watcher
   ```

2. Check task file format:
   ```bash
   cat inbox/task-*.json | jq .
   ```

3. Check agent status:
   ```sql
   SELECT * FROM ora_my-project.agents WHERE status = 'active';
   ```

**Solutions:**

**Solution 1: File watcher not running**
```bash
# Start file watcher
# Or use polling mechanism
# Or manually trigger agent
```

**Solution 2: Task format invalid**
- Validate JSON syntax
- Check required fields
- Ensure proper schema

**Solution 3: Agent not active**
```sql
-- Activate agent
UPDATE ora_my-project.agents 
SET status = 'active' 
WHERE agent_id = 'agent-1';
```

---

### Issue: Director not reading outputs

**Symptoms:**
- Output files in `outbox/` not processed
- Director not making decisions
- Tasks stuck completed

**Diagnosis:**
1. Check output files:
   ```bash
   ls -la outbox/
   cat outbox/msg-*.json | jq .
   ```

2. Check director process:
   ```bash
   ps aux | grep director
   ```

**Solutions:**

**Solution 1: Output format invalid**
- Validate JSON syntax
- Check output schema
- Fix format errors

**Solution 2: Director not running**
- Start director process
- Check director logs
- Verify director configuration

---

## Performance Issues

### Issue: Slow vector queries

**Symptoms:**
- Pinecone queries taking too long
- Agents waiting for memory queries
- Timeout errors

**Solutions:**

**Solution 1: Reduce top_k**
```python
# Reduce number of results
results = index.query(
    vector=query_vector,
    top_k=5,  # Instead of 10
    namespace="my-project"
)
```

**Solution 2: Add metadata filters**
```python
# Filter before query
results = index.query(
    vector=query_vector,
    top_k=10,
    namespace="my-project",
    filter={"project": "my-project", "type": "conversation"}
)
```

**Solution 3: Optimize index**
- Use appropriate dimension
- Choose right metric (cosine, euclidean)
- Consider index type (serverless vs pod)

---

### Issue: PostgreSQL queries slow

**Symptoms:**
- Database queries taking too long
- Agents waiting for state queries
- Connection timeouts

**Solutions:**

**Solution 1: Add indexes**
```sql
-- Add missing indexes
CREATE INDEX idx_tasks_status ON ora_my-project.tasks(status);
CREATE INDEX idx_agents_status ON ora_my-project.agents(status);
```

**Solution 2: Optimize queries**
```sql
-- Use specific columns
SELECT agent_id, status FROM ora_my-project.agents;

-- Add WHERE clauses
SELECT * FROM ora_my-project.tasks WHERE status = 'pending';
```

**Solution 3: Connection pooling**
- Use connection pooler (PgBouncer)
- Reduce connection overhead
- Reuse connections

---

## Getting More Help

If you're still stuck:

1. **Check Documentation**: See `/docs` directory
2. **Review Logs**: Check agent and director logs
3. **Validate Configuration**: Verify all environment variables
4. **Test Components**: Test each component individually
5. **Community Support**: Join `#ora-agents` Slack channel

---

## Common Error Messages

### "Schema already exists"
**Solution:** Use different project name or drop existing schema

### "Namespace already exists"
**Solution:** Namespace will be reused (this is OK)

### "Channel already exists"
**Solution:** Use different project name or delete existing channel

### "Invalid project name"
**Solution:** Use lowercase, alphanumeric, hyphens only

### "Missing environment variable"
**Solution:** Export required environment variables

---

**For specific issues not covered here, check component-specific documentation.**

