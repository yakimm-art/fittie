#!/bin/bash

# Create GitHub Labels for Fittie Project
# Run this BEFORE creating issues

set -e

echo "🏷️  Creating GitHub labels for Fittie project..."
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

echo "✅ GitHub CLI is installed and authenticated"
echo ""

# Priority Labels
echo "Creating priority labels..."
gh label create "p0" --description "Critical priority - must have" --color "d73a4a" --force
gh label create "p1" --description "High priority - should have" --color "ff9800" --force
gh label create "p2" --description "Medium priority - nice to have" --color "ffc107" --force
gh label create "p3" --description "Low priority - future enhancement" --color "4caf50" --force

# Category Labels
echo "Creating category labels..."
gh label create "setup" --description "Environment and project setup" --color "0052cc" --force
gh label create "infrastructure" --description "AWS infrastructure and IaC" --color "1d76db" --force
gh label create "backend" --description "Backend/Lambda/API development" --color "5319e7" --force
gh label create "frontend" --description "Flutter/PWA frontend development" --color "e99695" --force
gh label create "ai" --description "AI/ML and Bedrock integration" --color "7057ff" --force
gh label create "voice" --description "Voice coaching and ElevenLabs" --color "ff6b6b" --force
gh label create "testing" --description "Testing and validation" --color "c5def5" --force
gh label create "documentation" --description "Documentation and specs" --color "0075ca" --force
gh label create "deployment" --description "Deployment and CI/CD" --color "2ea44f" --force

# Technology Labels
echo "Creating technology labels..."
gh label create "aws" --description "Amazon Web Services" --color "ff9900" --force
gh label create "cdk" --description "AWS Cloud Development Kit" --color "ff9900" --force
gh label create "lambda" --description "AWS Lambda functions" --color "ff9900" --force
gh label create "dynamodb" --description "Amazon DynamoDB" --color "2962ff" --force
gh label create "s3" --description "Amazon S3 storage" --color "569a31" --force
gh label create "cognito" --description "Amazon Cognito auth" --color "dd344c" --force
gh label create "cloudfront" --description "Amazon CloudFront CDN" --color "8c4fff" --force
gh label create "bedrock" --description "Amazon Bedrock AI" --color "01a88d" --force
gh label create "eventbridge" --description "Amazon EventBridge" --color "ff4f8b" --force

gh label create "flutter" --description "Flutter framework" --color "02569b" --force
gh label create "dreamflow" --description "Dreamflow platform" --color "6f42c1" --force
gh label create "typescript" --description "TypeScript code" --color "007acc" --force
gh label create "nodejs" --description "Node.js runtime" --color "68a063" --force

# Component Labels
echo "Creating component labels..."
gh label create "state-manager" --description "Physical State Manager" --color "fbca04" --force
gh label create "voice-coaching" --description "Voice Coaching System" --color "d876e3" --force
gh label create "routine-generator" --description "Routine Generator" --color "bfd4f2" --force
gh label create "validator" --description "Biomechanical Validator" --color "c2e0c6" --force
gh label create "orchestrator" --description "Agentic Orchestrator" --color "5319e7" --force
gh label create "multi-surface" --description "Multi-Surface Sync" --color "1d76db" --force
gh label create "ui-engine" --description "Agentic UI Engine" --color "e99695" --force

# Phase Labels
echo "Creating phase labels..."
gh label create "phase-0" --description "Pre-Implementation Setup" --color "ededed" --force
gh label create "phase-1" --description "Infrastructure Foundation" --color "bfd4f2" --force
gh label create "phase-2" --description "Physical State Manager" --color "c5def5" --force
gh label create "phase-3" --description "UI Shell Development" --color "d4c5f9" --force
gh label create "phase-4" --description "Voice Coaching System" --color "f9d0c4" --force
gh label create "phase-5" --description "Routine Generator" --color "c2e0c6" --force
gh label create "phase-6" --description "Biomechanical Validator" --color "fef2c0" --force
gh label create "phase-7" --description "Agentic Orchestration" --color "bfdadc" --force
gh label create "phase-8" --description "Multi-Surface Sync" --color "d4c5f9" --force
gh label create "phase-9" --description "Polish & Demo Prep" --color "0e8a16" --force
gh label create "phase-10" --description "Testing & Launch" --color "b60205" --force

# Status Labels
echo "Creating status labels..."
gh label create "blocked" --description "Blocked by dependencies" --color "d93f0b" --force
gh label create "in-progress" --description "Currently being worked on" --color "0e8a16" --force
gh label create "needs-review" --description "Ready for code review" --color "fbca04" --force

# Special Labels
echo "Creating special labels..."
gh label create "bug" --description "Something isn't working" --color "d73a4a" --force
gh label create "enhancement" --description "New feature or request" --color "a2eeef" --force
gh label create "architecture" --description "Architecture and design decisions" --color "5319e7" --force
gh label create "performance" --description "Performance optimization" --color "ff6b6b" --force
gh label create "security" --description "Security-related issue" --color "d73a4a" --force
gh label create "cicd" --description "CI/CD and automation" --color "2ea44f" --force
gh label create "monitoring" --description "Monitoring and observability" --color "1d76db" --force
gh label create "configuration" --description "Configuration and environment" --color "0052cc" --force
gh label create "shared" --description "Shared code and types" --color "006b75" --force
gh label create "repository" --description "Data access layer" --color "0075ca" --force
gh label create "streams" --description "DynamoDB Streams" --color "2962ff" --force

echo ""
echo "✅ All GitHub labels created successfully!"
echo ""
echo "📊 Label Categories:"
echo "   - Priority: p0, p1, p2, p3"
echo "   - Category: setup, infrastructure, backend, frontend, ai, voice, testing, documentation, deployment"
echo "   - Technology: aws, cdk, lambda, dynamodb, s3, cognito, cloudfront, bedrock, eventbridge, flutter, dreamflow, typescript, nodejs"
echo "   - Component: state-manager, voice-coaching, routine-generator, validator, orchestrator, multi-surface, ui-engine"
echo "   - Phase: phase-0 through phase-10"
echo "   - Status: blocked, in-progress, needs-review"
echo "   - Special: bug, enhancement, architecture, performance, security, cicd, monitoring, configuration, shared, repository, streams"
echo ""
echo "🔗 View all labels: gh label list"
echo ""
echo "✨ Now you can run: ./scripts/create-github-issues.sh"
