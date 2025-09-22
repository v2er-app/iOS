#!/bin/bash

# Script to update app version
# Usage: ./scripts/update-version.sh [version] [build]
# Example: ./scripts/update-version.sh 1.1.3 31

CONFIG_FILE="V2er/Config/Version.xcconfig"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display current version
show_current_version() {
    CURRENT_VERSION=$(grep '^MARKETING_VERSION = ' "$CONFIG_FILE" | sed 's/.*MARKETING_VERSION = //' | xargs)
    CURRENT_BUILD=$(grep '^CURRENT_PROJECT_VERSION = ' "$CONFIG_FILE" | sed 's/.*CURRENT_PROJECT_VERSION = //' | xargs)
    echo -e "${YELLOW}Current version: ${NC}$CURRENT_VERSION (build $CURRENT_BUILD)"
}

# Function to update version
update_version() {
    local new_version=$1
    local new_build=$2

    # Update MARKETING_VERSION
    sed -i '' "s/^MARKETING_VERSION = .*/MARKETING_VERSION = $new_version/" "$CONFIG_FILE"

    # Update CURRENT_PROJECT_VERSION
    sed -i '' "s/^CURRENT_PROJECT_VERSION = .*/CURRENT_PROJECT_VERSION = $new_build/" "$CONFIG_FILE"

    echo -e "${GREEN}✅ Version updated successfully!${NC}"
}

# Main script
echo -e "${GREEN}=== V2er Version Update Tool ===${NC}\n"

# Show current version
show_current_version

# If no arguments provided, run in interactive mode
if [ $# -eq 0 ]; then
    echo ""
    read -p "Enter new version (e.g., 1.1.3): " NEW_VERSION
    read -p "Enter new build number (e.g., 31): " NEW_BUILD

    if [ -z "$NEW_VERSION" ] || [ -z "$NEW_BUILD" ]; then
        echo -e "${RED}❌ Error: Version and build number are required${NC}"
        exit 1
    fi
else
    # Use provided arguments
    NEW_VERSION=$1
    NEW_BUILD=$2

    if [ -z "$NEW_VERSION" ] || [ -z "$NEW_BUILD" ]; then
        echo -e "${RED}❌ Error: Usage: $0 <version> <build>${NC}"
        echo "Example: $0 1.1.3 31"
        exit 1
    fi
fi

# Confirm update
echo ""
echo -e "${YELLOW}Will update to:${NC} $NEW_VERSION (build $NEW_BUILD)"
read -p "Proceed? (y/n): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    update_version "$NEW_VERSION" "$NEW_BUILD"
    echo ""
    show_current_version
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Commit the changes: git add -A && git commit -m \"chore: bump version to $NEW_VERSION (build $NEW_BUILD)\""
    echo "2. Push to trigger release: git push"
else
    echo -e "${RED}❌ Update cancelled${NC}"
    exit 1
fi