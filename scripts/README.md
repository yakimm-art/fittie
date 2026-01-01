# Fittie Setup Scripts

This directory contains setup and utility scripts for the Fittie project.

## Setup Scripts

### setup-billing-alarms.sh

Sets up AWS CloudWatch billing alarms to monitor costs and avoid unexpected charges.

**Prerequisites:**
- AWS CLI installed and configured
- AWS account with billing access
- Email address for notifications

**Usage:**
```bash
./scripts/setup-billing-alarms.sh
```

The script will:
1. Create an SNS topic for billing alerts
2. Subscribe your email to receive notifications
3. Create a CloudWatch alarm for $50/month threshold
4. Provide instructions for email confirmation

**Configuration:**
- Default threshold: $50/month
- Region: us-east-1 (required for billing metrics)
- Alarm name: `fittie-billing-alarm`

**Manual Steps Required:**
1. Enable billing alerts in AWS Console:
   - Go to [Billing Preferences](https://console.aws.amazon.com/billing/home#/preferences)
   - Check "Receive Billing Alerts"
2. Confirm email subscription (check your inbox)

### create-github-issues.sh

Creates comprehensive GitHub issues for the Fittie project phases.

**Usage:**
```bash
./scripts/create-github-issues.sh
```

### create-github-labels.sh

Creates standardized labels for GitHub issue tracking.

**Usage:**
```bash
./scripts/create-github-labels.sh
```

### setup-github-secrets.sh

Configures GitHub repository secrets for CI/CD pipeline.

**Prerequisites:**
- GitHub CLI installed and authenticated
- Repository access with admin permissions

**Usage:**
```bash
./scripts/setup-github-secrets.sh
```

The script will prompt you to add:
- AWS credentials (Access Key ID and Secret)
- ElevenLabs API key
- Dreamflow API key (optional)

### test-elevenlabs.sh

Tests ElevenLabs API functionality and generates sample audio.

**Usage:**
```bash
export ELEVENLABS_API_KEY=your_key_here
./scripts/test-elevenlabs.sh
```

## CI/CD Pipeline

The project uses GitHub Actions for continuous integration. See [.github/workflows/ci.yml](.github/workflows/ci.yml).

**Workflow includes:**
- Code linting (ESLint, Prettier)
- Backend tests
- Script validation (ShellCheck)
- Infrastructure validation (AWS CDK)
- Security scanning (Trivy)

**To trigger workflow:**
- Push to `main` or `develop` branch
- Create pull request
- Manual dispatch from Actions tab

## Notes

- All scripts require appropriate authentication (AWS CLI, GitHub CLI)
- Scripts use `set -e` to exit on errors
- Check script output for success/failure messages
- Secrets are stored securely in GitHub and never committed to repository
