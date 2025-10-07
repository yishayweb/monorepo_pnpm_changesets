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
    local package_json="$package_dir/package.json"
    
    if [[ -f "$package_json" ]]; then
        echo "📦 Processing $package_json"
        
        # Extract current version using node
        current_version=$(node -p "require('$package_json').version")
        echo "   Current version: $current_version"
        
        # Create new version with branch tag
        new_version="${current_version}-${BRANCH_NAME}.0"
        echo "   New version: $new_version"
        
        # Update the package.json file
        node -e "
            const fs = require('fs');
            const pkg = JSON.parse(fs.readFileSync('$package_json', 'utf8'));
            pkg.version = '$new_version';
            fs.writeFileSync('$package_json', JSON.stringify(pkg, null, 2) + '\n');
        "
        
        echo "   ✅ Updated $package_json to version $new_version"
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