# Ora

**Omniscient. Real-time. Autonomous.**

The framework for autonomous AI development with unified memory across all your tools.

---

## What is Ora?

Ora synchronizes Claude, Cursor, GitHub, Pinecone, LangSmith, and Slack into a single autonomous development system with omniscient memory. One heartbeat. Perfect sync.

Ora enables you to create isolated, autonomous agent systems for any project in under 5 minutes. Each project gets its own PostgreSQL schema, Pinecone namespace, Slack channel, and agent workforce—completely isolated from other projects.

---

## Key Features

### 🧠 Omniscient Memory
- **Pinecone Vector Database**: Maintains perfect context across all agents and conversations
- **PostgreSQL State**: Persistent agent state, decision history, and performance metrics
- **Unified Knowledge**: All project knowledge accessible to every agent instantly

### ⚡ 15-Minute Oversight
- **Daily Strategic Reviews**: High-level oversight without micromanagement
- **Autonomous Execution**: Agents work independently between reviews
- **Perfect Coordination**: File-based communication ensures reliable agent coordination

### 🚀 Rapid Project Setup
- **5-Minute Bootstrap**: `ora-init my-project` creates everything you need
- **Complete Isolation**: Each project gets isolated infrastructure
- **Zero Configuration**: Works out of the box with sensible defaults

### 🤖 Agent Templates
- **Pre-built Archetypes**: Research, Implementation, QA, Documentation, Infrastructure agents
- **Instant Deployment**: Deploy agents in seconds using templates
- **Proven Patterns**: Based on production MCP-WP system (12+ agents, 2,426 vectors)

### 🔒 Perfect Isolation
- **PostgreSQL**: Schema isolation (`ora_{{PROJECT_NAME}}`)
- **Pinecone**: Namespace isolation (`{{PROJECT_NAME}}`)
- **Slack**: Channel isolation (`#ora-{{PROJECT_NAME}}-agents`)
- **File System**: Separate project directories

---

## Quick Start

### Prerequisites

- PostgreSQL database (local or remote)
- Pinecone account and API key
- Slack workspace and bot token
- Node.js and Python 3
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/your-org/ora.git
cd ora

# Set up environment variables
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=postgres
export DB_USER=postgres
export DB_PASSWORD=your-password
export PINECONE_API_KEY=your-pinecone-key
export PINECONE_INDEX_NAME=ora-framework-index
export SLACK_BOT_TOKEN=your-slack-token
```

### Create Your First Project

```bash
# Initialize a new project
cd infrastructure/bootstrap
./ora-init.sh my-awesome-project

# Your autonomous workforce is ready in < 5 minutes!
```

That's it! Ora will:
1. ✅ Create PostgreSQL schema (`ora_my-awesome-project`)
2. ✅ Create Pinecone namespace (`my-awesome-project`)
3. ✅ Create Slack channel (`#ora-my-awesome-project-agents`)
4. 📋 Guide you through LangSmith setup (manual)
5. 📋 Guide you through GitHub setup (manual)

### Deploy Your First Agents

```bash
# Deploy agents using templates
cd agent-templates/deploy
./ora-hire-agent.sh research-agent my-awesome-project
./ora-hire-agent.sh implementation-agent my-awesome-project
./ora-hire-agent.sh qa-agent my-awesome-project
```

---

## Architecture Overview

Ora is built on four core principles:

### 1. **Omniscient Memory**
Every agent has access to the complete project knowledge base through Pinecone vectors and PostgreSQL state. No context is lost.

### 2. **Infrastructure Isolation**
Each project gets completely isolated infrastructure:
- **PostgreSQL Schema**: `ora_{{PROJECT_NAME}}` - separate tables, no data mixing
- **Pinecone Namespace**: `{{PROJECT_NAME}}` - vector isolation via namespaces
- **Slack Channel**: `#ora-{{PROJECT_NAME}}-agents` - dedicated communication channel
- **File System**: `/projects/{{PROJECT_NAME}}/` - separate directories

### 3. **File-Based Communication**
Agents communicate via JSON files in `inbox/` and `outbox/` directories. This ensures:
- Reliability (no network dependencies)
- Auditability (all messages persisted)
- Simplicity (easy to debug and monitor)

### 4. **15-Minute Oversight**
The Director (Claude) reviews progress every 15 minutes, making strategic decisions while agents execute autonomously.

---

## Comparison to Alternatives

| Feature | Ora | LangChain | AutoGPT | Custom Setup |
|---------|-----|-----------|---------|--------------|
| **Setup Time** | 5 minutes | Hours | Hours | Days |
| **Memory System** | Unified (Pinecone + PostgreSQL) | Fragmented | Limited | Manual |
| **Project Isolation** | Built-in | Manual | Manual | Manual |
| **Agent Templates** | Pre-built | None | Limited | None |
| **Slack Integration** | Built-in | Manual | Manual | Manual |
| **Multi-Project** | Native | Difficult | Difficult | Difficult |

---

## Project Structure

```
ora/
├── infrastructure/          # Infrastructure templates
│   ├── postgres/           # PostgreSQL schema templates
│   ├── pinecone/           # Pinecone namespace setup
│   ├── slack/              # Slack channel creation
│   ├── langsmith/          # LangSmith project setup
│   ├── github/             # GitHub repository templates
│   └── bootstrap/          # Master bootstrap script (ora-init.sh)
├── agent-templates/        # Agent archetype templates
│   ├── archetypes/         # Agent type templates
│   ├── schemas/            # Communication schemas
│   └── deploy/             # Agent deployment scripts
├── core/                   # Core framework code
├── cli/                    # Command-line tools
├── docs/                   # Documentation
└── projects/               # Project instances
```

---

## Documentation

- **[QUICKSTART.md](docs/QUICKSTART.md)** - Get started in 10 minutes
- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Deep dive into system design
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[AGENT-TEMPLATES.md](docs/AGENT-TEMPLATES.md)** - Agent template guide
- **[TEST-RESULTS.md](docs/TEST-RESULTS.md)** - System test results

---

## Status

✅ **Production Ready** - Based on proven MCP-WP system (12+ agents, 2,426 vectors)

The Ora framework has been extracted from a production autonomous system and refined for multi-project use. All core functionality is tested and working.

---

## Contributing

We welcome contributions! Please see our contributing guidelines (coming soon).

Areas where we'd love help:
- Additional agent archetypes
- Integration with more tools
- Performance optimizations
- Documentation improvements

---

## License

**TBD** - Considering dual licensing:
- **Open-source core**: MIT License for core framework
- **Commercial enterprise**: Additional features and support

---

## Support

- 📖 **Documentation**: See `/docs` directory
- 💬 **Slack**: Join `#ora-agents` channel
- 🐛 **Issues**: GitHub Issues (coming soon)
- 📧 **Email**: support@ora.dev (coming soon)

---

## Acknowledgments

Ora is built on the proven patterns from the MCP-WP autonomous system, which successfully manages 12+ agents with 2,426 vectors in production.

---

**Built with ❤️ by the Ora team**
