#!/bin/bash
# Update Local Repository with New Setup Files
# Run this on your Raspberry Pi

echo "=========================================="
echo "Updating WiiFitBoardBit Repository"
echo "=========================================="
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "${GREEN}[STEP]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Step 1: Show current status
print_step "Checking current repository status..."
git status
echo ""

# Step 2: Fetch latest changes
print_step "Fetching latest changes from remote..."
git fetch origin
echo ""

# Step 3: Show available branches
print_step "Available branches with new setup:"
git branch -r | grep "claude/setup-raspberry-pi"
echo ""

# Step 4: Checkout the branch with setup files
SETUP_BRANCH="claude/setup-raspberry-pi-01AyJRn7S2oKfy4tJ2zZjN2Y"
print_step "Checking out branch with setup files..."
print_info "Branch: $SETUP_BRANCH"
echo ""

# Check if we're already on the branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" = "$SETUP_BRANCH" ]; then
    print_info "Already on $SETUP_BRANCH, pulling latest changes..."
    git pull origin "$SETUP_BRANCH"
else
    # Check if local branch exists
    if git show-ref --verify --quiet "refs/heads/$SETUP_BRANCH"; then
        print_info "Local branch exists, switching and pulling..."
        git checkout "$SETUP_BRANCH"
        git pull origin "$SETUP_BRANCH"
    else
        print_info "Creating local branch from remote..."
        git checkout -b "$SETUP_BRANCH" "origin/$SETUP_BRANCH"
    fi
fi

echo ""

# Step 5: Verify new files are present
print_step "Verifying new setup files..."
NEW_FILES=(
    "setup_raspberry_pi.sh"
    "QUICKSTART.md"
    "SETUP_GUIDE.md"
    "TROUBLESHOOTING.md"
    "install_service.sh"
    "wiifitboardbit.service"
)

all_present=true
for file in "${NEW_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${YELLOW}✗${NC} $file (missing)"
        all_present=false
    fi
done

echo ""

if [ "$all_present" = true ]; then
    print_step "All files successfully updated! ✓"
    echo ""
    echo "You can now run the setup:"
    echo "  ./setup_raspberry_pi.sh"
    echo ""
    echo "Or read the quick start guide:"
    echo "  cat QUICKSTART.md"
else
    echo -e "${YELLOW}Some files are missing. Try running 'git pull' again.${NC}"
fi
