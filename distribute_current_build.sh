#!/bin/bash

# Script to distribute the current TestFlight build to beta testers
# This is useful when a build was uploaded but not automatically distributed

echo "🚀 Distributing current TestFlight build to beta testers..."

# Run the distribute_beta lane to handle the latest build
fastlane distribute_beta

echo "✅ Distribution process completed!"