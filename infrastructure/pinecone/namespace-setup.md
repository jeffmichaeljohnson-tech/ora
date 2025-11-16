# Pinecone Namespace Strategy for Ora Framework

## Overview

Pinecone namespaces provide perfect isolation between projects in a shared index. Each Ora project gets its own namespace, ensuring complete data separation while sharing the same Pinecone index infrastructure.

## Naming Convention

- **Namespace Format**: `{project_name}` (lowercase, hyphenated)
- **Example**: Project `my-awesome-app` → Namespace `my-awesome-app`
- **Index**: Shared across all projects (single index, multiple namespaces)

## Architecture

```
Pinecone Index: ora-framework-index
├── Namespace: project-1
│   ├── Vectors: All vectors for project-1
│   └── Metadata: Tagged with project: "project-1"
├── Namespace: project-2
│   ├── Vectors: All vectors for project-2
│   └── Metadata: Tagged with project: "project-2"
└── Namespace: project-3
    ├── Vectors: All vectors for project-3
    └── Metadata: Tagged with project: "project-3"
```

## Vector Metadata Tagging Pattern

All vectors uploaded to a namespace must include project metadata:

```json
{
  "id": "vector-id-123",
  "values": [...],
  "metadata": {
    "project": "my-awesome-app",
    "type": "cursor_conversation",
    "source": "cursor",
    "timestamp": "2025-01-16T00:00:00Z",
    "conversation_id": "conv-123",
    "agent_id": "agent-33"
  }
}
```

### Required Metadata Fields

- `project`: Project name (matches namespace)
- `type`: Vector type (`cursor_conversation`, `documentation`, `code`)
- `source`: Source system (`cursor`, `github`, `langsmith`, `slack`)
- `timestamp`: ISO 8601 timestamp

### Optional Metadata Fields

- `conversation_id`: For conversation vectors
- `agent_id`: For agent-specific vectors
- `file_path`: For code/documentation vectors
- `commit_hash`: For GitHub vectors

## Namespace Isolation Strategy

### 1. **Query Isolation**
All queries must specify the namespace:

```python
index.query(
    vector=query_vector,
    top_k=10,
    namespace="my-awesome-app",  # Required!
    include_metadata=True
)
```

### 2. **Upsert Isolation**
All upserts must target the correct namespace:

```python
index.upsert(
    vectors=[...],
    namespace="my-awesome-app",  # Required!
    ids=[...]
)
```

### 3. **Metadata Filtering** (Defense in Depth)
Even within a namespace, filter by project metadata:

```python
index.query(
    vector=query_vector,
    top_k=10,
    namespace="my-awesome-app",
    filter={
        "project": {"$eq": "my-awesome-app"}  # Extra safety
    }
)
```

## Namespace Creation Workflow

1. **Validate Project Name**
   - Lowercase, alphanumeric, hyphens only
   - No spaces or special characters

2. **Check Namespace Existence**
   - Query index stats to see if namespace exists
   - If exists, verify it's empty or confirm overwrite

3. **Create Namespace** (Implicit)
   - Namespaces are created automatically on first upsert
   - No explicit creation API needed

4. **Verify Namespace**
   - Upsert a test vector
   - Query it back
   - Delete test vector

5. **Document Namespace**
   - Add to project configuration
   - Update namespace-to-project mapping

## Namespace-to-Project Mapping

Maintain a configuration file mapping namespaces to projects:

```json
{
  "namespaces": {
    "my-awesome-app": {
      "project_name": "my-awesome-app",
      "created_at": "2025-01-16T00:00:00Z",
      "vector_count": 1242,
      "index_name": "ora-framework-index"
    },
    "another-project": {
      "project_name": "another-project",
      "created_at": "2025-01-15T12:00:00Z",
      "vector_count": 856,
      "index_name": "ora-framework-index"
    }
  }
}
```

## Best Practices

1. **Always Specify Namespace**
   - Never query/upsert without namespace
   - Default namespace is dangerous (cross-project contamination)

2. **Validate Before Operations**
   - Check namespace exists before querying
   - Verify project name matches namespace

3. **Monitor Namespace Size**
   - Track vector counts per namespace
   - Set alerts for rapid growth

4. **Cleanup Strategy**
   - Archive old namespaces before deletion
   - Export vectors before namespace deletion

5. **Error Handling**
   - Handle namespace-not-found gracefully
   - Retry with exponential backoff

## Migration Strategy

When migrating from single-namespace to multi-namespace:

1. **Backup Existing Vectors**
   - Export all vectors from default namespace
   - Tag with project metadata

2. **Create New Namespaces**
   - One namespace per project
   - Use project name as namespace

3. **Re-upload Vectors**
   - Filter by project metadata
   - Upload to correct namespace

4. **Update Application Code**
   - Add namespace parameter to all queries
   - Update upsert operations

5. **Verify Isolation**
   - Query each namespace independently
   - Confirm no cross-contamination

## Troubleshooting

### Namespace Not Found
- **Cause**: Namespace doesn't exist yet
- **Solution**: Namespace created on first upsert, or check spelling

### Cross-Namespace Contamination
- **Cause**: Missing namespace parameter in query/upsert
- **Solution**: Always specify namespace explicitly

### Performance Issues
- **Cause**: Large namespace or inefficient queries
- **Solution**: Use metadata filtering, limit top_k, paginate results

## API Reference

See `create-namespace.py` for implementation examples.

