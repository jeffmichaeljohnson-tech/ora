# Ora Framework - Architecture Documentation

**Deep dive into system design, isolation strategy, and agent coordination patterns.**

---

## Table of Contents

1. [System Design Philosophy](#system-design-philosophy)
2. [Infrastructure Isolation Strategy](#infrastructure-isolation-strategy)
3. [Agent Coordination Patterns](#agent-coordination-patterns)
4. [Memory Architecture](#memory-architecture)
5. [Communication Protocol](#communication-protocol)
6. [Director Pattern](#director-pattern)
7. [Scaling Considerations](#scaling-considerations)

---

## System Design Philosophy

Ora is built on four core principles:

### 1. **Perfect Isolation**

Every project instance is completely isolated from others:
- **No shared state**: Each project has its own database schema, vector namespace, and communication channels
- **No cross-contamination**: Projects cannot interfere with each other
- **Independent scaling**: Scale projects independently without affecting others

### 2. **Omniscient Memory**

Every agent has access to complete project knowledge:
- **Unified context**: Pinecone vectors + PostgreSQL state = complete picture
- **No context loss**: All conversations, decisions, and knowledge persist
- **Instant access**: Agents query memory instantly, no delays

### 3. **Autonomous Execution**

Agents work independently with minimal oversight:
- **15-minute reviews**: Director reviews progress every 15 minutes
- **Autonomous execution**: Agents work independently between reviews
- **Strategic decisions**: Director makes high-level decisions, agents execute

### 4. **File-Based Reliability**

Communication via files ensures reliability:
- **No network dependencies**: Works offline, no API rate limits
- **Audit trail**: All messages persisted for debugging
- **Simple debugging**: Easy to inspect and modify messages

---

## Infrastructure Isolation Strategy

### PostgreSQL Schema Isolation

**Pattern:** `ora_{{PROJECT_NAME}}`

Each project gets its own PostgreSQL schema with complete isolation:

```sql
-- Project: my-project
CREATE SCHEMA ora_my-project;

-- Project: another-project  
CREATE SCHEMA ora_another-project;

-- MCP-WP (original project)
-- Uses different schema (not ora_* prefix)
```

**Benefits:**
- ✅ Complete data isolation
- ✅ Independent backups
- ✅ Easy project deletion (DROP SCHEMA)
- ✅ No naming conflicts
- ✅ Multi-tenancy support

**Schema Structure:**
```sql
ora_{{PROJECT_NAME}}/
├── agents              -- Agent registry
├── tasks               -- Task tracking
├── director_decisions  -- Strategic decisions
└── performance_metrics -- Performance tracking
```

### Pinecone Namespace Isolation

**Pattern:** Namespace = `{{PROJECT_NAME}}`

Each project gets its own Pinecone namespace:

```python
# Project: my-project
namespace = "my-project"

# Project: another-project
namespace = "another-project"

# MCP-WP (original project)
namespace = "mcp-wp"  # Different namespace
```

**Benefits:**
- ✅ Vector isolation via namespaces
- ✅ Independent vector management
- ✅ Easy namespace deletion
- ✅ No vector mixing
- ✅ Metadata tagging for extra safety

**Vector Metadata Pattern:**
```json
{
  "id": "vector-123",
  "values": [...],
  "metadata": {
    "project": "my-project",
    "type": "conversation",
    "source": "agent-1",
    "timestamp": "2025-01-16T00:00:00Z"
  }
}
```

### Slack Channel Isolation

**Pattern:** `#ora-{{PROJECT_NAME}}-agents`

Each project gets its own Slack channel:

```
#ora-my-project-agents
#ora-another-project-agents
#ora-agents  (MCP-WP original)
```

**Benefits:**
- ✅ Separate communication channels
- ✅ Project-specific notifications
- ✅ Easy channel management
- ✅ No message mixing
- ✅ Team-specific access control

### File System Isolation

**Pattern:** `/projects/{{PROJECT_NAME}}/`

Each project gets its own directory:

```
/projects/my-project/
├── agents/
│   └── _queue/
│       ├── inbox/
│       └── outbox/
├── docs/
└── code/

/projects/another-project/
└── ...
```

**Benefits:**
- ✅ Complete file isolation
- ✅ Independent version control
- ✅ Easy project deletion
- ✅ No file conflicts
- ✅ Project-specific configurations

---

## Agent Coordination Patterns

### File-Based Communication

Agents communicate via JSON files in `inbox/` and `outbox/` directories:

```
agents/_queue/
├── inbox/           # Tasks assigned to agents
│   └── task-*.json
├── outbox/          # Agent outputs
│   └── msg-*.json
└── processed/       # Completed tasks
    └── task-*.json
```

**Message Flow:**
1. Director creates task file → `inbox/task-123.json`
2. Agent reads task file → Processes task
3. Agent creates output file → `outbox/msg-456.json`
4. Agent moves task → `processed/task-123.json`
5. Director reads output → Makes next decision

**Benefits:**
- ✅ Reliable (no network failures)
- ✅ Auditable (all messages persisted)
- ✅ Simple (easy to debug)
- ✅ Offline-capable (works without internet)

### Task Schema

All tasks follow a standardized schema:

```json
{
  "agentId": "agent-1",
  "priority": "HIGH",
  "messageType": "NEW_TASK_ASSIGNMENT",
  "timestamp": "2025-01-16T00:00:00Z",
  "task": {
    "title": "Task Title",
    "description": "Task description",
    "objective": "What we want to achieve",
    "context": {
      "projectName": "my-project"
    },
    "phases": [...],
    "successCriteria": {...}
  }
}
```

### Heartbeat Pattern

Agents report progress every 5 minutes:

```json
{
  "agentId": "agent-1",
  "timestamp": "2025-01-16T00:05:00Z",
  "messageType": "HEARTBEAT",
  "status": "in_progress",
  "progress": {
    "phase": 1,
    "tasksCompleted": 3,
    "tasksRemaining": 2
  }
}
```

---

## Memory Architecture

### Two-Tier Memory System

Ora uses a two-tier memory system:

#### Tier 1: Pinecone (Vector Memory)

**Purpose:** Semantic search and context retrieval

**Content:**
- Conversation history
- Code snippets
- Documentation
- Decisions and reasoning

**Query Pattern:**
```python
# Search for relevant context
results = index.query(
    vector=query_vector,
    top_k=10,
    namespace="my-project",
    filter={"project": "my-project"}
)
```

#### Tier 2: PostgreSQL (State Memory)

**Purpose:** Structured data and agent state

**Content:**
- Agent registry
- Task tracking
- Performance metrics
- Director decisions

**Query Pattern:**
```sql
-- Get agent status
SELECT * FROM ora_my-project.agents WHERE agent_id = 'agent-1';

-- Get task history
SELECT * FROM ora_my-project.tasks WHERE agent_id = 'agent-1';
```

### Memory Synchronization

Memory is synchronized automatically:
- **Vectors created** → Stored in Pinecone with project metadata
- **State changes** → Recorded in PostgreSQL
- **Queries** → Search both Pinecone and PostgreSQL
- **Consistency** → Both systems stay in sync

---

## Communication Protocol

### Message Types

1. **NEW_TASK_ASSIGNMENT**: Director assigns task to agent
2. **HEARTBEAT**: Agent reports progress
3. **TASK_COMPLETE**: Agent completes task
4. **BLOCKER_ALERT**: Agent encounters blocker
5. **DIRECTOR_SUMMARY**: Director provides strategic update

### Message Flow

```
Director → inbox/task-123.json → Agent reads
Agent → outbox/msg-456.json → Director reads
Agent → processed/task-123.json → Task archived
```

### Error Handling

- **Invalid JSON**: Task rejected, error logged
- **Missing fields**: Task rejected, error logged
- **Agent unavailable**: Task queued, retried later
- **Processing failure**: Task moved to failed/, alert sent

---

## Director Pattern

### 15-Minute Review Cycle

The Director (Claude) reviews progress every 15 minutes:

1. **Read agent outputs** from `outbox/`
2. **Query memory** for context (Pinecone + PostgreSQL)
3. **Make strategic decisions**:
   - Assign new tasks
   - Resolve blockers
   - Adjust priorities
   - Retire/fire agents
4. **Post summary** to Slack
5. **Wait 15 minutes** → Repeat

### Decision Making

Director decisions are:
- **Strategic**: High-level, not tactical
- **Data-driven**: Based on agent outputs and memory
- **Context-aware**: Uses full project history
- **Recorded**: All decisions stored in PostgreSQL

### Escalation

Agents can escalate blockers:
- **Automatic escalation**: After 20 minutes of no progress
- **Manual escalation**: Agent creates blocker alert
- **Director response**: Reviews and resolves within 15 minutes

---

## Scaling Considerations

### Horizontal Scaling

**Multiple Projects:**
- Each project is isolated
- No shared resources
- Scale projects independently
- No cross-project interference

**Multiple Agents:**
- Agents work independently
- File-based communication scales
- No bottlenecks
- Add agents as needed

### Vertical Scaling

**PostgreSQL:**
- Each schema isolated
- Independent indexes
- Scale per project
- No shared connections

**Pinecone:**
- Namespace isolation
- Independent vector counts
- Scale per project
- No shared quotas

### Performance Optimization

**Memory Queries:**
- Cache frequent queries
- Batch vector operations
- Index PostgreSQL tables
- Optimize vector dimensions

**File Operations:**
- Use file watchers for real-time updates
- Batch file reads
- Compress old messages
- Archive processed tasks

---

## Security Considerations

### Isolation Security

- **Schema-level isolation**: PostgreSQL schemas prevent cross-project access
- **Namespace isolation**: Pinecone namespaces prevent vector mixing
- **Channel isolation**: Slack channels prevent message leakage
- **File isolation**: Directory permissions prevent file access

### Access Control

- **Database users**: Project-specific database users (recommended)
- **API keys**: Separate API keys per project (recommended)
- **Slack tokens**: Project-specific bot tokens (optional)
- **File permissions**: Restrict file access per project

### Data Protection

- **Backups**: Project-specific backups
- **Encryption**: Encrypt sensitive data at rest
- **Audit logs**: Log all agent actions
- **Compliance**: Meet data protection requirements

---

## Future Enhancements

### Planned Features

1. **Multi-cloud support**: Deploy across AWS, GCP, Azure
2. **Kubernetes integration**: Containerized agent deployment
3. **Real-time updates**: WebSocket-based communication
4. **Advanced analytics**: Performance dashboards
5. **Agent marketplace**: Share agent templates

### Research Areas

1. **Agent learning**: Agents learn from past tasks
2. **Predictive scaling**: Auto-scale based on workload
3. **Cross-project insights**: Learn from all projects
4. **Advanced memory**: More sophisticated memory systems

---

## Conclusion

Ora's architecture is designed for:
- ✅ **Isolation**: Perfect project isolation
- ✅ **Scalability**: Horizontal and vertical scaling
- ✅ **Reliability**: File-based communication
- ✅ **Simplicity**: Easy to understand and debug

The system is production-ready and proven in the MCP-WP autonomous system.

---

**For implementation details, see individual component documentation.**

