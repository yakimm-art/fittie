#!/bin/bash

# GitHub Secrets Setup Script
# This script helps configure GitHub repository secrets

set -e

echo "🔐 GitHub Secrets Setup for Fittie"
echo "===================================="
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ Error: GitHub CLI (gh) is not installed."
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub CLI."
    echo "Run: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI is authenticated"
echo ""

# Get repository info
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "Repository: $REPO"
echo ""

echo "This script will help you add the following secrets:"
echo "  1. AWS_ACCESS_KEY_ID"
echo "  2. AWS_SECRET_ACCESS_KEY"
echo "  3. ELEVENLABS_API_KEY"
echo "  4. DREAMFLOW_API_KEY (optional)"
echo ""

read -p "Do you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "📝 Setting up secrets..."
echo ""

# AWS Access Key ID
echo "1. AWS_ACCESS_KEY_ID"
if gh secret list | grep -q "AWS_ACCESS_KEY_ID"; then
    echo "   ⚠️  Secret already exists"
    read -p "   Update? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Enter AWS Access Key ID:"
        read -r AWS_KEY_ID
        echo "$AWS_KEY_ID" | gh secret set AWS_ACCESS_KEY_ID
        echo "   ✅ Updated AWS_ACCESS_KEY_ID"
    fi
else
    echo "   Enter AWS Access Key ID:"
    read -r AWS_KEY_ID
    echo "$AWS_KEY_ID" | gh secret set AWS_ACCESS_KEY_ID
    echo "   ✅ Set AWS_ACCESS_KEY_ID"
fi
echo ""

# AWS Secret Access Key
echo "2. AWS_SECRET_ACCESS_KEY"
if gh secret list | grep -q "AWS_SECRET_ACCESS_KEY"; then
    echo "   ⚠️  Secret already exists"
    read -p "   Update? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Enter AWS Secret Access Key:"
        read -rs AWS_SECRET_KEY
        echo
        echo "$AWS_SECRET_KEY" | gh secret set AWS_SECRET_ACCESS_KEY
        echo "   ✅ Updated AWS_SECRET_ACCESS_KEY"
    fi
else
    echo "   Enter AWS Secret Access Key:"
    read -rs AWS_SECRET_KEY
    echo
    echo "$AWS_SECRET_KEY" | gh secret set AWS_SECRET_ACCESS_KEY
    echo "   ✅ Set AWS_SECRET_ACCESS_KEY"
fi
echo ""

# ElevenLabs API Key
echo "3. ELEVENLABS_API_KEY"
if gh secret list | grep -q "ELEVENLABS_API_KEY"; then
    echo "   ⚠️  Secret already exists"
    read -p "   Update? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "   Enter ElevenLabs API Key:"
        read -rs ELEVENLABS_KEY
        echo
        echo "$ELEVENLABS_KEY" | gh secret set ELEVENLABS_API_KEY
        echo "   ✅ Updated ELEVENLABS_API_KEY"
    fi
else
    echo "   Enter ElevenLabs API Key:"
    read -rs ELEVENLABS_KEY
    echo
    echo "$ELEVENLABS_KEY" | gh secret set ELEVENLABS_API_KEY
    echo "   ✅ Set ELEVENLABS_API_KEY"
fi
echo ""

# Dreamflow API Key (optional)
echo "4. DREAMFLOW_API_KEY (optional)"
read -p "   Do you have a Dreamflow API key to add? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if gh secret list | grep -q "DREAMFLOW_API_KEY"; then
        echo "   ⚠️  Secret already exists"
        read -p "   Update? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "   Enter Dreamflow API Key:"
            read -rs DREAMFLOW_KEY
            echo
            echo "$DREAMFLOW_KEY" | gh secret set DREAMFLOW_API_KEY
            echo "   ✅ Updated DREAMFLOW_API_KEY"
        fi
    else
        echo "   Enter Dreamflow API Key:"
        read -rs DREAMFLOW_KEY
        echo
        echo "$DREAMFLOW_KEY" | gh secret set DREAMFLOW_API_KEY
        echo "   ✅ Set DREAMFLOW_API_KEY"
    fi
fi
echo ""

echo "🎉 GitHub secrets setup complete!"
echo ""
echo "Current secrets:"
gh secret list
echo ""
echo "Next steps:"
echo "  1. Enable branch protection for 'main' branch"
echo "  2. Require pull request reviews before merging"
echo "  3. Require status checks to pass (CI workflow)"
echo ""
echo "To enable branch protection:"
echo "  gh api repos/$REPO/branches/main/protection -X PUT -f required_status_checks[strict]=true -f required_status_checks[contexts][]=build-status"
echo ""
