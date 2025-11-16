#!/usr/bin/env python3
"""
Pinecone Namespace Creation Script for Ora Framework
Creates and validates namespace for new project instances
"""

import os
import sys
import json
from datetime import datetime
from typing import Dict, Optional
from pinecone import Pinecone, ServerlessSpec
from pinecone.exceptions import PineconeException

# Configuration
PINECONE_API_KEY = os.getenv('PINECONE_API_KEY')
PINECONE_INDEX_NAME = os.getenv('PINECONE_INDEX_NAME', 'ora-framework-index')
PINECONE_ENVIRONMENT = os.getenv('PINECONE_ENVIRONMENT', 'us-east-1-aws')

# Colors for output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def print_error(message: str):
    """Print error message"""
    print(f"{Colors.RED}❌ {message}{Colors.NC}")

def print_success(message: str):
    """Print success message"""
    print(f"{Colors.GREEN}✅ {message}{Colors.NC}")

def print_warning(message: str):
    """Print warning message"""
    print(f"{Colors.YELLOW}⚠️  {message}{Colors.NC}")

def print_info(message: str):
    """Print info message"""
    print(f"{Colors.BLUE}ℹ️  {message}{Colors.NC}")

def validate_project_name(project_name: str) -> bool:
    """Validate project name format"""
    if not project_name:
        return False
    
    # Lowercase, alphanumeric, hyphens only
    if not all(c.islower() and (c.isalnum() or c == '-') for c in project_name):
        return False
    
    # Cannot start/end with hyphen
    if project_name.startswith('-') or project_name.endswith('-'):
        return False
    
    # Minimum length
    if len(project_name) < 2:
        return False
    
    return True

def get_namespace_stats(pc: Pinecone, index_name: str, namespace: str) -> Optional[Dict]:
    """Get statistics for a namespace"""
    try:
        index = pc.Index(index_name)
        stats = index.describe_index_stats()
        
        # Check if namespace exists in stats
        namespaces = stats.get('namespaces', {})
        if namespace in namespaces:
            return namespaces[namespace]
        return None
    except Exception as e:
        print_error(f"Failed to get namespace stats: {e}")
        return None

def create_test_vector() -> Dict:
    """Create a test vector for namespace validation"""
    import numpy as np
    
    # Generate random 1536-dimensional vector (OpenAI ada-002 dimension)
    vector = np.random.rand(1536).tolist()
    
    return {
        "id": "namespace-test-vector",
        "values": vector,
        "metadata": {
            "project": "test",
            "type": "test",
            "source": "namespace-creation",
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
    }

def verify_namespace(pc: Pinecone, index_name: str, namespace: str) -> bool:
    """Verify namespace exists and is accessible"""
    try:
        index = pc.Index(index_name)
        
        # Create test vector
        test_vector = create_test_vector()
        
        # Upsert test vector
        print_info("Upserting test vector...")
        index.upsert(
            vectors=[test_vector],
            namespace=namespace
        )
        
        # Query it back
        print_info("Querying test vector...")
        results = index.query(
            vector=test_vector["values"],
            top_k=1,
            namespace=namespace,
            include_metadata=True
        )
        
        if results.matches and len(results.matches) > 0:
            # Delete test vector
            print_info("Deleting test vector...")
            index.delete(ids=["namespace-test-vector"], namespace=namespace)
            return True
        
        return False
    except Exception as e:
        print_error(f"Namespace verification failed: {e}")
        return False

def create_namespace(project_name: str, verify: bool = True) -> bool:
    """Create and validate namespace for project"""
    
    # Validate inputs
    if not PINECONE_API_KEY:
        print_error("PINECONE_API_KEY environment variable not set")
        return False
    
    if not validate_project_name(project_name):
        print_error("Invalid project name format")
        print("Project name must be:")
        print("  - Lowercase only")
        print("  - Alphanumeric and hyphens only")
        print("  - Cannot start/end with hyphen")
        print("  - Example: 'my-project' or 'awesome-app'")
        return False
    
    namespace = project_name  # Namespace = project name
    
    print(f"{Colors.GREEN}{'='*80}")
    print("  PINECONE NAMESPACE CREATION")
    print("="*80)
    print(f"{Colors.NC}")
    print(f"Project Name: {Colors.YELLOW}{project_name}{Colors.NC}")
    print(f"Namespace:    {Colors.YELLOW}{namespace}{Colors.NC}")
    print(f"Index:        {Colors.YELLOW}{PINECONE_INDEX_NAME}{Colors.NC}")
    print(f"{Colors.GREEN}{'='*80}{Colors.NC}")
    print()
    
    try:
        # Initialize Pinecone
        print_info("Connecting to Pinecone...")
        pc = Pinecone(api_key=PINECONE_API_KEY)
        
        # Check if index exists
        try:
            index = pc.Index(PINECONE_INDEX_NAME)
            print_success(f"Index '{PINECONE_INDEX_NAME}' found")
        except Exception as e:
            print_error(f"Index '{PINECONE_INDEX_NAME}' not found")
            print("Create the index first or set PINECONE_INDEX_NAME to existing index")
            return False
        
        # Check if namespace already exists
        stats = get_namespace_stats(pc, PINECONE_INDEX_NAME, namespace)
        if stats:
            vector_count = stats.get('vector_count', 0)
            print_warning(f"Namespace '{namespace}' already exists ({vector_count} vectors)")
            
            if vector_count > 0:
                response = input("Namespace has existing vectors. Continue anyway? (y/N): ")
                if response.lower() != 'y':
                    print("Aborted")
                    return False
        
        # Verify namespace (creates it implicitly)
        if verify:
            print_info("Verifying namespace (this creates it if it doesn't exist)...")
            if verify_namespace(pc, PINECONE_INDEX_NAME, namespace):
                print_success("Namespace verified and accessible")
            else:
                print_error("Namespace verification failed")
                return False
        else:
            print_info("Namespace will be created on first vector upsert")
        
        # Get final stats
        final_stats = get_namespace_stats(pc, PINECONE_INDEX_NAME, namespace)
        if final_stats:
            vector_count = final_stats.get('vector_count', 0)
            print()
            print_success("Namespace ready!")
            print(f"  Namespace: {namespace}")
            print(f"  Vectors:  {vector_count}")
            print()
            print("Next Steps:")
            print("  1. Update application to use namespace: " + namespace)
            print("  2. Always specify namespace in queries/upserts")
            print("  3. Tag vectors with project metadata")
            return True
        else:
            print_warning("Namespace created but stats not available yet")
            print("This is normal - namespace will be fully available after first upsert")
            return True
            
    except PineconeException as e:
        print_error(f"Pinecone API error: {e}")
        return False
    except Exception as e:
        print_error(f"Unexpected error: {e}")
        return False

def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        print("Usage: python create-namespace.py <project-name> [--no-verify]")
        print()
        print("Example:")
        print("  python create-namespace.py my-awesome-project")
        print()
        print("Environment Variables:")
        print("  PINECONE_API_KEY       - Pinecone API key (required)")
        print("  PINECONE_INDEX_NAME    - Index name (default: ora-framework-index)")
        print("  PINECONE_ENVIRONMENT  - Environment (default: us-east-1-aws)")
        sys.exit(1)
    
    project_name = sys.argv[1]
    verify = "--no-verify" not in sys.argv
    
    success = create_namespace(project_name, verify=verify)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()

