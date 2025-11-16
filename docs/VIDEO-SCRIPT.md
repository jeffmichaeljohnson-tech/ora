# Ora Framework - Video Demo Script

**Script outline for creating a video demonstration of Ora framework.**

---

## Video Overview

**Title:** "Ora Framework: Autonomous AI Development in 5 Minutes"

**Duration:** 10-12 minutes

**Target Audience:** Developers, technical leads, AI enthusiasts

**Goal:** Show how to set up a complete autonomous agent system in under 5 minutes

---

## Scene Breakdown

### Scene 1: Introduction (0:00 - 1:00)

**Visual:** Screen recording of terminal, Ora logo

**Script:**
```
"Hi, I'm [Name], and today I'm going to show you how to set up 
a complete autonomous AI development system in under 5 minutes 
using the Ora framework.

Ora synchronizes Claude, Cursor, GitHub, Pinecone, LangSmith, 
and Slack into a single autonomous development system with 
omniscient memory. One heartbeat. Perfect sync.

Let's get started!"
```

**Action:** Show Ora README, highlight key features

---

### Scene 2: Prerequisites Check (1:00 - 2:00)

**Visual:** Terminal commands, checklist

**Script:**
```
"Before we begin, let's make sure we have everything we need:

First, we need a PostgreSQL database. I have one running locally.

Next, we need a Pinecone account. I've already created an index.

We also need a Slack workspace with a bot token configured.

And finally, we need Node.js and Python installed.

Let me verify these are set up..."
```

**Action:**
- Check PostgreSQL: `pg_isready`
- Check Pinecone: Show API key (masked)
- Check Slack: Show bot token (masked)
- Check Node/Python: `node --version`, `python3 --version`

---

### Scene 3: Installation (2:00 - 3:00)

**Visual:** Terminal commands, file tree

**Script:**
```
"Now let's clone the Ora repository and install dependencies.

First, we'll clone the repo, then install Node.js dependencies 
for the Slack integration, and Python dependencies for Pinecone."
```

**Action:**
```bash
git clone https://github.com/your-org/ora.git
cd ora
cd infrastructure/slack && npm install
cd ../..
pip3 install pinecone-client
```

---

### Scene 4: Environment Setup (3:00 - 4:00)

**Visual:** Terminal, .env file

**Script:**
```
"Now we need to configure our environment variables. I'll set 
up the database connection, Pinecone API key, and Slack bot token."
```

**Action:**
```bash
export DB_HOST=localhost
export DB_PORT=5432
export DB_NAME=postgres
export DB_USER=postgres
export DB_PASSWORD=***
export PINECONE_API_KEY=***
export PINECONE_INDEX_NAME=ora-framework-index
export SLACK_BOT_TOKEN=xoxb-***
```

**Visual:** Show masked values, explain what each does

---

### Scene 5: Project Creation (4:00 - 6:00)

**Visual:** Terminal, ora-init.sh execution

**Script:**
```
"This is where the magic happens. With a single command, Ora 
will create all the infrastructure we need for our project.

Let's create a project called 'demo-project'..."
```

**Action:**
```bash
cd infrastructure/bootstrap
./ora-init.sh demo-project
```

**Visual:** Show output:
- PostgreSQL schema creation
- Pinecone namespace creation
- Slack channel creation
- Manual setup instructions

**Script:**
```
"Perfect! In under a minute, Ora has created:
- A PostgreSQL schema for our project
- A Pinecone namespace for vector storage
- A Slack channel for agent communication

Notice how everything is isolated - this project won't interfere 
with any other projects we create."
```

---

### Scene 6: Verification (6:00 - 7:00)

**Visual:** Terminal queries, Slack UI

**Script:**
```
"Let's verify everything was created correctly. First, let's 
check the PostgreSQL schema..."
```

**Action:**
```bash
psql -c "\dn ora_*"
psql -c "SELECT * FROM ora_demo-project.agents;"
```

**Script:**
```
"Great! The schema exists. Now let's check Pinecone..."
```

**Action:**
```python
python3 -c "
from pinecone import Pinecone
pc = Pinecone(api_key='$PINECONE_API_KEY')
index = pc.Index('$PINECONE_INDEX_NAME')
stats = index.describe_index_stats()
print(stats)
"
```

**Script:**
```
"And finally, let's check Slack..."
```

**Visual:** Show Slack workspace, #ora-demo-project-agents channel

---

### Scene 7: Agent Deployment (7:00 - 9:00)

**Visual:** Terminal, agent templates

**Script:**
```
"Now let's deploy some agents. Ora comes with pre-built agent 
templates for common tasks like research, implementation, QA, 
and documentation.

Let's deploy a research agent..."
```

**Action:**
```bash
cd ../../agent-templates/deploy
./ora-hire-agent.sh research-agent demo-project
./ora-hire-agent.sh implementation-agent demo-project
./ora-hire-agent.sh qa-agent demo-project
```

**Visual:** Show agent directory structure, template files

**Script:**
```
"Perfect! We now have three agents ready to work. Each agent 
has its own directory with inbox and outbox for communication.

Let's create a task for our research agent..."
```

**Action:** Create task file in inbox

---

### Scene 8: Task Execution (9:00 - 10:00)

**Visual:** Task file, agent processing, output

**Script:**
```
"Here's a task for our research agent. It will research best 
practices for autonomous agent systems and create a comprehensive 
report.

The agent will:
1. Read the task from the inbox
2. Query Pinecone for relevant context
3. Conduct research
4. Create deliverables
5. Post updates to Slack

Let's watch it work..."
```

**Visual:** Show agent processing (simulated or time-lapse)

**Script:**
```
"Notice how the agent:
- Has access to all project memory via Pinecone
- Can query PostgreSQL for agent state
- Posts updates to Slack automatically
- Creates structured outputs

This is the power of Ora's omniscient memory system."
```

---

### Scene 9: Results & Next Steps (10:00 - 11:00)

**Visual:** Output files, Slack messages, summary

**Script:**
```
"Let's check the results. Our research agent has created:
- A comprehensive research catalog
- An analysis report
- A findings summary

All posted to Slack for easy review.

What's next? You can:
- Deploy more agents
- Create custom agent types
- Integrate with GitHub
- Scale to multiple projects

Each project is completely isolated, so you can run as many 
as you need without interference."
```

**Visual:** Show output files, Slack channel

---

### Scene 10: Conclusion (11:00 - 12:00)

**Visual:** Summary slide, links

**Script:**
```
"In under 5 minutes, we've:
✅ Set up complete infrastructure
✅ Deployed multiple agents
✅ Created and executed tasks
✅ Verified everything works

Ora makes autonomous AI development accessible to everyone.

To get started:
- Clone the repository
- Follow the quick start guide
- Deploy your first agents

Links are in the description below.

Thanks for watching!"
```

**Visual:** Show links:
- GitHub repository
- Documentation
- Quick start guide
- Community Slack

---

## Production Notes

### Recording Setup

- **Screen Resolution:** 1920x1080
- **Terminal:** Use dark theme, large font (18-20pt)
- **Terminal Colors:** High contrast for visibility
- **Slack:** Use light theme, show channel clearly

### Editing Tips

- **Speed Up:** 1.5x for installation steps
- **Highlight:** Use cursor highlight for important commands
- **Zoom:** Zoom in on terminal output when showing results
- **Transitions:** Smooth transitions between scenes

### Audio

- **Voice:** Clear, enthusiastic, professional
- **Background Music:** Light, non-distracting (optional)
- **Sound Effects:** Subtle notification sounds for Slack

### Graphics

- **Intro:** Ora logo animation
- **Transitions:** Smooth fade between scenes
- **Callouts:** Highlight important information
- **End Screen:** Subscribe, links, social media

---

## Key Messages

1. **Speed:** Set up in under 5 minutes
2. **Isolation:** Perfect project isolation
3. **Memory:** Omniscient memory system
4. **Simplicity:** Single command setup
5. **Power:** Production-ready system

---

## Call to Action

- **Try Ora:** Clone and run ora-init
- **Join Community:** Slack #ora-agents
- **Contribute:** GitHub contributions welcome
- **Share:** Share your Ora projects

---

## Additional Scenes (Optional)

### Advanced: Custom Agent Creation

Show how to create custom agent types

### Advanced: Multi-Project Setup

Show multiple projects running simultaneously

### Advanced: Integration Examples

Show GitHub, LangSmith integrations

---

**Total Runtime:** ~12 minutes (with optional scenes)

**Target:** Clear, concise, actionable demonstration

