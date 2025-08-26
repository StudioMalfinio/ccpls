#!/bin/bash

echo "Initializing..."
echo ""
echo ""

echo " ██████╗ ██████╗██████╗ ███╗   ███╗"
echo "██╔════╝██╔════╝██╔══██╗████╗ ████║"
echo "██║     ██║     ██████╔╝██╔████╔██║"
echo "╚██████╗╚██████╗██║     ██║ ╚═╝ ██║"
echo " ╚═════╝ ╚═════╝╚═╝     ╚═╝     ╚═╝"

echo "┌─────────────────────────────────┐"
echo "│ Claude Code Project Management  │"
echo "│ by https://x.com/aroussi        │"
echo "└─────────────────────────────────┘"
echo "https://github.com/automazeio/ccpm"
echo ""
echo ""

echo "🚀 Initializing Claude Code PM System"
echo "======================================"
echo ""

# Hybrid mode: Check for command-line arguments or use interactive prompts
if [ $# -gt 0 ]; then
  # Automated mode - argument provided
  case "$1" in
    github)
      GIT_SYSTEM="github"
      echo "🔧 Git hosting platform: GitHub (automated mode)"
      ;;
    gitlab)
      GIT_SYSTEM="gitlab"
      echo "🔧 Git hosting platform: GitLab (automated mode)"
      ;;
    *)
      echo "❌ Invalid argument. Usage: $0 [github|gitlab]"
      echo "   Or run without arguments for interactive mode."
      exit 1
      ;;
  esac
else
  # Interactive mode - no arguments provided
  echo "🔧 Choose your Git hosting platform:"
  echo "  1. GitHub"
  echo "  2. GitLab"
  echo ""
  read -p "Enter your choice (1-2): " git_choice

  case $git_choice in
    1)
      GIT_SYSTEM="github"
      echo "  ✅ GitHub selected"
      ;;
    2)
      GIT_SYSTEM="gitlab"
      echo "  ✅ GitLab selected"
      ;;
    *)
      echo "  ❌ Invalid choice. Initialization cancelled."
      exit 1
      ;;
  esac
fi

echo ""

# Check for required tools
echo "🔍 Checking dependencies..."

# Check and install CLI tools based on selected system
if [ "$GIT_SYSTEM" = "github" ]; then
  # Check gh CLI
  if command -v gh &> /dev/null; then
    echo "  ✅ GitHub CLI (gh) installed"
  else
    echo "  ❌ GitHub CLI (gh) not found"
    echo ""
    echo "  Installing gh..."
    if command -v brew &> /dev/null; then
      brew install gh
    elif command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install gh
    else
      echo "  Please install GitHub CLI manually: https://cli.github.com/"
      exit 1
    fi
  fi
elif [ "$GIT_SYSTEM" = "gitlab" ]; then
  # Check glab CLI
  if command -v glab &> /dev/null; then
    echo "  ✅ GitLab CLI (glab) installed"
  else
    echo "  ❌ GitLab CLI (glab) not found"
    echo ""
    echo "  Installing glab..."
    if command -v brew &> /dev/null; then
      brew install glab
    elif command -v apt-get &> /dev/null; then
      sudo apt-get update && sudo apt-get install glab
    else
      echo "  Please install GitLab CLI manually: https://gitlab.com/gitlab-org/cli"
      exit 1
    fi
  fi
fi

# Authentication based on selected system
echo ""
if [ "$GIT_SYSTEM" = "github" ]; then
  echo "🔐 Checking GitHub authentication..."
  if gh auth status &> /dev/null; then
    echo "  ✅ GitHub authenticated"
  else
    echo "  ⚠️ GitHub not authenticated"
    if [ $# -gt 0 ]; then
      # Automated mode - provide instructions
      echo "  📝 To authenticate, run: gh auth login"
      echo "  ℹ️ Continuing without authentication..."
    else
      # Interactive mode - attempt login
      echo "  Please authenticate with GitHub:"
      gh auth login
    fi
  fi
elif [ "$GIT_SYSTEM" = "gitlab" ]; then
  echo "🔐 Checking GitLab authentication..."
  if glab auth status &> /dev/null; then
    echo "  ✅ GitLab authenticated"
  else
    echo "  ⚠️ GitLab not authenticated"
    if [ $# -gt 0 ]; then
      # Automated mode - provide instructions
      echo "  📝 To authenticate, run: glab auth login"
      echo "  ℹ️ Continuing without authentication..."
    else
      # Interactive mode - attempt login
      echo "  Please authenticate with GitLab:"
      glab auth login
    fi
  fi
fi

# Check for extensions based on selected system
echo ""
if [ "$GIT_SYSTEM" = "github" ]; then
  echo "📦 Checking GitHub CLI extensions..."
  if gh extension list | grep -q "yahsan2/gh-sub-issue"; then
    echo "  ✅ gh-sub-issue extension installed"
  else
    echo "  📥 Installing gh-sub-issue extension..."
    gh extension install yahsan2/gh-sub-issue
  fi
elif [ "$GIT_SYSTEM" = "gitlab" ]; then
  echo "📦 GitLab CLI ready (no additional extensions needed)"
fi

# Create directory structure
echo ""
echo "📁 Creating directory structure..."
mkdir -p .claude/prds
mkdir -p .claude/epics
mkdir -p .claude/rules
mkdir -p .claude/agents
mkdir -p .claude/scripts/pm
echo "  ✅ Directories created"

# Copy scripts if in main repo
if [ -d "scripts/pm" ] && [ ! "$(pwd)" = *"/.claude"* ]; then
  echo ""
  echo "📝 Copying PM scripts..."
  cp -r scripts/pm/* .claude/scripts/pm/
  chmod +x .claude/scripts/pm/*.sh
  echo "  ✅ Scripts copied and made executable"
fi

# Check for git
echo ""
echo "🔗 Checking Git configuration..."
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo "  ✅ Git repository detected"

  # Check remote
  if git remote -v | grep -q origin; then
    remote_url=$(git remote get-url origin)
    echo "  ✅ Remote configured: $remote_url"
  else
    echo "  ⚠️ No remote configured"
    echo "  Add with: git remote add origin <url>"
  fi
else
  echo "  ⚠️ Not a git repository"
  echo "  Initialize with: git init"
fi

# Create CLAUDE.md if it doesn't exist
if [ ! -f "CLAUDE.md" ]; then
  echo ""
  echo "📄 Creating CLAUDE.md..."
  cat > CLAUDE.md << 'EOF'
# CLAUDE.md

> Think carefully and implement the most concise solution that changes as little code as possible.

## Project-Specific Instructions

Add your project-specific instructions here.

## Testing

Always run tests before committing:
- `npm test` or equivalent for your stack

## Code Style

Follow existing patterns in the codebase.
EOF
  echo "  ✅ CLAUDE.md created"
fi

# Summary
echo ""
echo "✅ Initialization Complete!"
echo "=========================="
echo ""
echo "📊 System Status:"
if [ "$GIT_SYSTEM" = "github" ]; then
  gh --version | head -1
  echo "  Extensions: $(gh extension list | wc -l) installed"
  echo "  Auth: $(gh auth status 2>&1 | grep -o 'Logged in to [^ ]*' || echo 'Not authenticated')"
elif [ "$GIT_SYSTEM" = "gitlab" ]; then
  glab --version | head -1
  echo "  Auth: $(glab auth status 2>&1 | grep -o 'Logged in to [^ ]*' || echo 'Not authenticated')"
fi
echo ""
echo "🎯 Next Steps:"
echo "  1. Create your first PRD: /pm:prd-new <feature-name>"
echo "  2. View help: /pm:help"
echo "  3. Check status: /pm:status"
echo ""
echo "📚 Documentation: README.md"

exit 0
