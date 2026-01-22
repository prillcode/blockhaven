# BlockHaven AWS Deployment Plan

## Pre-Deployment Checklist

### 1. Make GitHub Repo Public
- [ ] Go to https://github.com/prillcode/blockhaven/settings
- [ ] Scroll to "Danger Zone" → Change visibility → Make public
- [ ] Verify: `curl -s https://api.github.com/repos/prillcode/blockhaven | jq .private` should return `false`

### 2. Create EC2 Key Pair (if not exists)
- [ ] Go to https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:
- [ ] Create key pair named `blockhaven-key` (or similar)
- [ ] Download .pem file to `~/.ssh/blockhaven-key.pem`
- [ ] Set permissions: `chmod 400 ~/.ssh/blockhaven-key.pem`

### 3. Create .env.aws Configuration
```bash
cd /home/prill/projects/blockhaven/mc-server/aws
cp .env.aws.example .env.aws
```

Edit `.env.aws` with these values:
```bash
# AWS Configuration
AWS_REGION=us-east-1
AWS_PROFILE=bgrweb

# CloudFormation Stack Name
STACK_NAME=blockhaven-mc

# S3 Backup Bucket (already exists)
S3_BUCKET=blockhaven-mc-backups

# EC2 Key Pair Name (from step 2)
KEY_PAIR_NAME=blockhaven-key

# Path to SSH private key
SSH_KEY_FILE=~/.ssh/blockhaven-key.pem

# Server Configuration
RCON_PASSWORD=<your-secure-password>
SERVER_OPS=PRLLAGER207

# Instance Configuration - Start with Spot for cost savings
INSTANCE_TYPE=t3a.large
VOLUME_SIZE=50
USE_ELASTIC_IP=true
USE_SPOT_INSTANCE=true

# Security - Restrict SSH to your IP (recommended)
# Get your IP: curl -s ifconfig.me
ALLOWED_SSH_CIDR=<your-ip>/32

# Git Repository
GIT_REPO_URL=https://github.com/prillcode/blockhaven.git
GIT_BRANCH=main
```

---

## Deployment Steps

### Step 1: Deploy the Stack
```bash
cd /home/prill/projects/blockhaven/mc-server/aws

# Dry run first to verify config
./deploy.sh --dry-run

# Deploy for real
./deploy.sh
```

**Expected time:** 5-10 minutes

### Step 2: Verify Deployment
```bash
# Check status
./status.sh

# Should show:
# - Instance: running
# - Minecraft: starting → online (after 2-3 min)
```

### Step 3: Test Connection
```bash
# Get the public IP
./status.sh | grep "Public IP"

# Test Minecraft port
nc -vz <public-ip> 25565

# Connect in Minecraft:
# Java: <public-ip>:25565
# Bedrock: <public-ip>:19132
```

### Step 4: SSH Access (if needed)
```bash
ssh -i ~/.ssh/blockhaven-key.pem ec2-user@<public-ip>

# View Minecraft logs
docker logs -f blockhaven-mc

# Check user-data script log
cat /var/log/user-data.log
```

---

## Testing Stop/Start Cycle

### Stop Server (with backup)
```bash
./stop-server.sh

# This will:
# 1. Announce shutdown in-game
# 2. Create backup and upload to S3
# 3. Stop the EC2 instance
```

### Start Server
```bash
./start-server.sh --wait --connect

# This will:
# 1. Start the EC2 instance
# 2. Wait for Minecraft to be ready
# 3. Show connection info
```

---

## Cost Monitoring

After a few hours of testing, check costs:
```bash
# In AWS Console: Cost Explorer
# Or use CLI:
aws ce get-cost-and-usage \
  --time-period Start=2026-01-22,End=2026-01-23 \
  --granularity DAILY \
  --metrics BlendedCost \
  --profile bgrweb
```

**Expected costs for testing session:**
- Spot t3a.large: ~$0.02-0.03/hour
- EBS 50GB: ~$0.13/day
- Elastic IP (while running): free
- Data transfer: minimal for testing

---

## Troubleshooting

### Stack creation failed
```bash
# Check CloudFormation events
aws cloudformation describe-stack-events \
  --stack-name blockhaven-mc \
  --profile bgrweb \
  --query "StackEvents[?ResourceStatus=='CREATE_FAILED']"
```

### Server not starting
```bash
# SSH in and check logs
ssh -i ~/.ssh/blockhaven-key.pem ec2-user@<ip>
cat /var/log/user-data.log
docker logs blockhaven-mc
```

### Can't connect to Minecraft
1. Check security group allows your IP
2. Wait 2-3 minutes after start
3. Verify with: `nc -vz <ip> 25565`

### Spot instance interrupted
- Instance will stop (not terminate)
- Data is safe on EBS
- Start again with `./start-server.sh`
- If persistent issues, switch to On-Demand:
  ```bash
  # Edit .env.aws: USE_SPOT_INSTANCE=false
  ./deploy.sh --update
  ```

---

## Cleanup (if needed)

To delete everything except the EBS volume:
```bash
./deploy.sh --delete
```

To also delete the EBS volume (loses all world data):
```bash
# Get volume ID first
aws ec2 describe-volumes --filters "Name=tag:Name,Values=blockhaven-mc-data" --profile bgrweb

# Delete it
aws ec2 delete-volume --volume-id vol-xxx --profile bgrweb
```
