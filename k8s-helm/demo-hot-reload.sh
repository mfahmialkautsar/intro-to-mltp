#!/bin/bash

# Demo script showing the development workflow with Skaffold
# This script demonstrates hot reloading capabilities

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}🔧 $1${NC}"
}

log_demo() {
    echo -e "${YELLOW}🎬 $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

echo "🎭 Mythical Beasts Development Demo"
echo "This demo shows hot reloading with Skaffold"
echo ""

# Step 1: Show current code
log_demo "Step 1: Current mythical-server code"
echo "Current server response message:"
grep -n "server up and running" ../source/mythical-beasts-server/index.js || echo "Not found"
echo ""

# Step 2: Make a simple change
log_demo "Step 2: Making a development change"
log_info "Adding timestamp to server startup message..."

# Backup original file
cp ../source/mythical-beasts-server/index.js ../source/mythical-beasts-server/index.js.backup

# Make a simple change that's visible in logs
sed -i.tmp 's/server up and running\.\.\./server up and running at '"$(date +%H:%M:%S)"'.../' ../source/mythical-beasts-server/index.js

echo "Modified line:"
grep -n "server up and running at" ../source/mythical-beasts-server/index.js
echo ""

# Step 3: Show what will happen
log_demo "Step 3: What happens with Skaffold hot reload"
echo "1. Skaffold detects the file change"
echo "2. File is synced to the running container"
echo "3. Node.js picks up the change automatically"
echo "4. No container restart required!"
echo ""

# Step 4: Instructions for user
log_demo "Step 4: To see this in action"
echo "1. Start development mode: ./start-dev.sh"
echo "2. Watch the logs: kubectl logs -f -n mltp-dev deployment/grafana-mltp-stack-mythical-server"
echo "3. The change above will be synced automatically"
echo "4. You'll see the new timestamp in the startup message"
echo ""

# Step 5: Restore original
log_demo "Step 5: Restoring original file"
mv ../source/mythical-beasts-server/index.js.backup ../source/mythical-beasts-server/index.js
rm -f ../source/mythical-beasts-server/index.js.tmp
log_success "Original file restored"
echo ""

log_demo "🚀 Ready for development!"
echo "Run './start-dev.sh' to start the development environment"
echo "Then try making changes to files in ../source/ and watch them sync!"
