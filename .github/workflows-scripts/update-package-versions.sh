#!/bin/bash
"""
Script to update package versions with branch tag.
Usage: ./update-package-versions.sh <branch_name>
"""

set -e  # Exit on any error

BRANCH_NAME="$1"

if [ -z "$BRANCH_NAME" ]; then
    echo "Usage: ./update-package-versions.sh <branch_name>"
    exit 1
fi

echo "🔄 Updating package versions with branch tag: $BRANCH_NAME"

# Function to update package.json version
update_package_version() {
    local package_dir=$1
    # Remove trailing slash if present
    package_dir=${package_dir%/}
    local package_json="$package_dir/package.json"
    
    if [[ -f "$package_json" ]]; then
        echo "📦 Processing $package_json"
        
        # Change to package directory for npm commands
        cd "$package_dir"
        
        # Extract current version using npm
        current_version=$(npm pkg get version | tr -d '"')
        echo "   Current version: $current_version"
        
        # Create new version with branch tag
        new_version="${current_version}-${BRANCH_NAME}.0"
        echo "   New version: $new_version"
        
        # Update the package.json version using npm
        npm pkg set version="$new_version"
        
        echo "   ✅ Updated $package_json to version $new_version"
        
        # Return to original directory
        cd - > /dev/null
    else
        echo "   ⚠️  No package.json found in $package_dir"
    fi
}

# Check if packages directory exists
if [[ ! -d "packages" ]]; then
    echo "❌ Error: packages directory not found"
    exit 1
fi

echo "📁 Scanning packages directory..."

# Process all packages in the packages directory
package_count=0
for package_dir in packages/*/; do
    if [[ -d "$package_dir" ]]; then
        echo "📂 Found package directory: $package_dir"
        update_package_version "$package_dir"
        ((package_count++))
    fi
done

if [ $package_count -eq 0 ]; then
    echo "⚠️  No packages found in packages/ directory"
else
    echo "🎉 Successfully updated $package_count packages with branch tag: $BRANCH_NAME"
fi