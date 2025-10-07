#!/usr/bin/env python3
"""
Script to update the release workflow with a new branch.
Usage: python3 update-release-workflow.py <branch_name>
"""

import sys
import os

def update_release_workflow(branch_name):
    """Update release.yml to include the new branch."""
    workflow_path = '.github/workflows/release.yml'
    
    if not os.path.exists(workflow_path):
        print(f"Error: {workflow_path} not found")
        sys.exit(1)
    
    # Read the release.yml file
    with open(workflow_path, 'r') as f:
        content = f.read()
    
    # Split content into lines for manual processing since it's a workflow file
    lines = content.split('\n')
    new_lines = []
    branch_added = False
    
    for line in lines:
        new_lines.append(line)
        # Look for the main branch line and add our branch after it
        if '- main' in line and not branch_added:
            # Add the new branch with the same indentation
            indent = line[:line.index('- main')]
            new_lines.append(f'{indent}- {branch_name}')
            branch_added = True
    
    if not branch_added:
        print("Warning: Could not find '- main' branch in release.yml")
        sys.exit(1)
    
    # Write back to file
    with open(workflow_path, 'w') as f:
        f.write('\n'.join(new_lines))
    
    print(f'✅ Updated release.yml with branch: {branch_name}')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: python3 update-release-workflow.py <branch_name>")
        sys.exit(1)
    
    branch_name = sys.argv[1]
    update_release_workflow(branch_name)