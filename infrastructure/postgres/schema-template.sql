-- Ora Framework PostgreSQL Schema Template
-- Schema naming convention: ora_{{PROJECT_NAME}}
-- Replace {{PROJECT_NAME}} with your actual project name (lowercase, hyphenated)

-- Create schema for project isolation
CREATE SCHEMA IF NOT EXISTS ora_{{PROJECT_NAME}};

-- Set search path to project schema
SET search_path TO ora_{{PROJECT_NAME}}, public;

-- ============================================================================
-- AGENTS TABLE
-- ============================================================================
-- Tracks all agents in the autonomous system
CREATE TABLE IF NOT EXISTS ora_{{PROJECT_NAME}}.agents (
    agent_id VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    specialty VARCHAR(255) NOT NULL,
    agent_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'active',
    performance_score FLOAT DEFAULT 0.0,
    tasks_completed INTEGER DEFAULT 0,
    tasks_failed INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    retired_at TIMESTAMP,
    last_active TIMESTAMP,
    metadata JSONB
);

-- ============================================================================
-- TASKS TABLE
-- ============================================================================
-- Tracks all tasks assigned to agents
CREATE TABLE IF NOT EXISTS ora_{{PROJECT_NAME}}.tasks (
    task_id VARCHAR(255) PRIMARY KEY,
    agent_id VARCHAR(255) REFERENCES ora_{{PROJECT_NAME}}.agents(agent_id),
    description TEXT NOT NULL,
    priority INTEGER DEFAULT 1,
    status VARCHAR(50) DEFAULT 'pending',
    deliverables JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    quality_score FLOAT,
    notes TEXT
);

-- ============================================================================
-- DIRECTOR DECISIONS TABLE
-- ============================================================================
-- Records strategic decisions made by the director agent
CREATE TABLE IF NOT EXISTS ora_{{PROJECT_NAME}}.director_decisions (
    decision_id SERIAL PRIMARY KEY,
    decision_type VARCHAR(100) NOT NULL,
    agent_id VARCHAR(255),
    reasoning TEXT NOT NULL,
    outcome TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    metadata JSONB
);

-- ============================================================================
-- PERFORMANCE METRICS TABLE
-- ============================================================================
-- Tracks performance metrics for agents over time
CREATE TABLE IF NOT EXISTS ora_{{PROJECT_NAME}}.performance_metrics (
    metric_id SERIAL PRIMARY KEY,
    agent_id VARCHAR(255) REFERENCES ora_{{PROJECT_NAME}}.agents(agent_id),
    metric_name VARCHAR(100) NOT NULL,
    metric_value FLOAT NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_agents_status ON ora_{{PROJECT_NAME}}.agents(status);
CREATE INDEX IF NOT EXISTS idx_agents_performance ON ora_{{PROJECT_NAME}}.agents(performance_score DESC);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON ora_{{PROJECT_NAME}}.tasks(status);
CREATE INDEX IF NOT EXISTS idx_tasks_agent ON ora_{{PROJECT_NAME}}.tasks(agent_id);
CREATE INDEX IF NOT EXISTS idx_director_decisions_created ON ora_{{PROJECT_NAME}}.director_decisions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_performance_metrics_agent ON ora_{{PROJECT_NAME}}.performance_metrics(agent_id);
CREATE INDEX IF NOT EXISTS idx_performance_metrics_recorded ON ora_{{PROJECT_NAME}}.performance_metrics(recorded_at DESC);

-- ============================================================================
-- GRANT PERMISSIONS
-- ============================================================================
-- Grant necessary permissions (adjust user/role as needed)
-- GRANT ALL PRIVILEGES ON SCHEMA ora_{{PROJECT_NAME}} TO your_app_user;
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ora_{{PROJECT_NAME}} TO your_app_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA ora_{{PROJECT_NAME}} TO your_app_user;

-- ============================================================================
-- USAGE NOTES
-- ============================================================================
-- 1. Replace {{PROJECT_NAME}} with your project name (e.g., 'my-project' becomes 'ora_my-project')
-- 2. Ensure PostgreSQL user has CREATE SCHEMA permissions
-- 3. Run this script: psql -U postgres -d your_database -f schema-template.sql
-- 4. Or use the create-schema.sh script for automated setup
-- 5. Each project gets isolated schema: perfect multi-tenancy

