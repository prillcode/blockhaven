# BlockHaven AWS Deployment

On-demand EC2 infrastructure for running the BlockHaven Minecraft server. Start when you want to play, stop when done to minimize costs.

## Quick Start

```bash
# 1. Configure
cp .env.aws.example .env.aws
# Edit .env.aws with your settings (key pair, passwords, etc.)

# 2. Deploy infrastructure (first time only)
./deploy.sh

# 3. Start playing
./start-server.sh --wait

# 4. When done
./stop-server.sh
```

## Cost Analysis

### Instance Type Comparison

| Type | vCPU | RAM | On-Demand/hr | On-Demand/day | Spot/hr* | Recommendation |
|------|------|-----|--------------|---------------|----------|----------------|
| **t3a.large** | 2 | 8GB | $0.0752 | $1.80 | ~$0.023 | **Best value** |
| t3.large | 2 | 8GB | $0.0832 | $2.00 | ~$0.025 | Good alternative |
| m6a.large | 2 | 8GB | $0.0864 | $2.07 | ~$0.026 | More consistent |
| t3a.xlarge | 4 | 16GB | $0.1504 | $3.61 | ~$0.045 | Heavy modpacks |

*Spot prices vary by AZ and time. Typically 60-70% cheaper but can be interrupted.

### Monthly Cost Scenarios

**Casual Gaming (4 hrs/day, 3 days/week)**
- On-Demand t3a.large: ~$4.33/month + $4 EBS = **~$8.33/month**
- Spot t3a.large: ~$1.30/month + $4 EBS = **~$5.30/month**

**Regular Gaming (4 hrs/day, every day)**
- On-Demand t3a.large: ~$9.02/month + $4 EBS = **~$13/month**
- Spot t3a.large: ~$2.76/month + $4 EBS = **~$6.76/month**

**Always On (24/7)**
- On-Demand t3a.large: ~$55/month + $4 EBS = **~$59/month**
- Spot t3a.large: ~$17/month + $4 EBS = **~$21/month**

### Fixed Costs (when stopped)

| Resource | Monthly Cost | Notes |
|----------|--------------|-------|
| EBS Volume (50GB gp3) | ~$4.00 | Stores worlds/data |
| Elastic IP (unattached) | ~$3.60 | Only if using EIP |
| S3 Backups | ~$0.50 | Depends on backup size |
| **Total (stopped)** | **~$4-8** | |

## Files

```
aws/
├── cloudformation.yaml    # Infrastructure as Code template
├── deploy.sh              # Deploy/update/delete the stack
├── start-server.sh        # Start the EC2 instance
├── stop-server.sh         # Backup and stop instance
├── status.sh              # Check server status
├── .env.aws.example       # Configuration template
└── README.md              # This file
```

## Prerequisites

1. **AWS CLI** installed and configured
   ```bash
   aws configure --profile bgrweb
   ```

2. **EC2 Key Pair** in your target region
   - Create at: https://console.aws.amazon.com/ec2/v2/home#KeyPairs:
   - Download the .pem file and save securely
   - Set permissions: `chmod 400 ~/.ssh/your-key.pem`

3. **S3 Bucket** for backups (already exists: `blockhaven-mc-backups`)

4. **jq** and **nc** for helper scripts
   ```bash
   # Ubuntu/Debian
   sudo apt install jq netcat-openbsd

   # macOS
   brew install jq netcat
   ```

## Detailed Usage

### Initial Deployment

```bash
# Copy and configure
cp .env.aws.example .env.aws
nano .env.aws  # Fill in your values

# Deploy the stack
./deploy.sh

# Wait for server to be ready (2-3 min)
./status.sh --watch
```

### Daily Usage

```bash
# Start playing
./start-server.sh --wait --connect

# Check status anytime
./status.sh

# Done for the day (backs up automatically)
./stop-server.sh
```

### Connecting

- **Java Edition**: `<public-ip>:25565`
- **Bedrock Edition**: `<public-ip>:19132`

Get the IP with:
```bash
./status.sh | grep "Public IP"
```

### SSH Access

```bash
# Connect to server
ssh -i ~/.ssh/your-key.pem ec2-user@<public-ip>

# View Minecraft logs
ssh ec2-user@<ip> 'docker logs -f blockhaven-mc'

# Run RCON commands
ssh ec2-user@<ip> 'docker exec blockhaven-mc rcon-cli "list"'
```

### Backup & Restore

Backups happen automatically when you run `./stop-server.sh`.

```bash
# Manual backup (while running)
ssh ec2-user@<ip> '/data/mc-server/backup-to-s3.sh'

# List backups
aws s3 ls s3://blockhaven-mc-backups/ --profile bgrweb

# Restore specific backup (on EC2)
ssh ec2-user@<ip>
cd /data/mc-server
# Edit restore-from-s3.sh to specify backup, then run it
```

## Spot Instances

Spot instances are 60-70% cheaper but can be interrupted with 2 minutes notice.

**Enable Spot:**
```bash
# In .env.aws
USE_SPOT_INSTANCE=true

# Redeploy
./deploy.sh --update
```

**Handling Interruptions:**
- AWS sends a 2-minute warning before termination
- The Minecraft server will auto-save every 30 seconds
- Worst case: lose up to 2 minutes of progress
- Instance restarts automatically when Spot capacity returns

**Recommendation:** Use Spot for casual/solo play. Use On-Demand for multiplayer sessions where uptime matters.

## Troubleshooting

### Server won't start

```bash
# Check instance status
./status.sh

# Check EC2 user-data logs
ssh ec2-user@<ip> 'sudo cat /var/log/user-data.log'

# Check Docker status
ssh ec2-user@<ip> 'docker ps -a'
ssh ec2-user@<ip> 'docker logs blockhaven-mc'
```

### Can't connect to Minecraft

1. Check security group allows your IP
2. Wait 2-3 minutes after start for server to initialize
3. Verify with: `nc -vz <ip> 25565`

### Backup failed

```bash
# Check S3 access
aws s3 ls s3://blockhaven-mc-backups/ --profile bgrweb

# Run backup manually with debug
ssh ec2-user@<ip> 'bash -x /data/mc-server/backup-to-s3.sh'
```

### Stack deployment failed

```bash
# View detailed events
aws cloudformation describe-stack-events \
  --stack-name blockhaven-mc \
  --profile bgrweb \
  --query "StackEvents[?ResourceStatus=='CREATE_FAILED']"
```

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        AWS Cloud                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                    VPC (Default)                     │   │
│  │  ┌───────────────────────────────────────────────┐  │   │
│  │  │              Security Group                    │  │   │
│  │  │  ┌─────────────────────────────────────────┐  │  │   │
│  │  │  │         EC2 Instance (t3a.large)        │  │  │   │
│  │  │  │  ┌──────────────────────────────────┐   │  │  │   │
│  │  │  │  │     Docker                       │   │  │  │   │
│  │  │  │  │  ┌────────────────────────────┐  │   │  │  │   │
│  │  │  │  │  │   itzg/minecraft-server    │  │   │  │  │   │
│  │  │  │  │  │   (Paper 1.21.11)          │  │   │  │  │   │
│  │  │  │  │  │   - Geyser (Bedrock)       │  │   │  │  │   │
│  │  │  │  │  │   - Multiverse             │  │   │  │  │   │
│  │  │  │  │  │   - Plugins...             │  │   │  │  │   │
│  │  │  │  │  └────────────────────────────┘  │   │  │  │   │
│  │  │  │  └──────────────────────────────────┘   │  │  │   │
│  │  │  └────────────────┬────────────────────────┘  │  │   │
│  │  │                   │                           │  │   │
│  │  │  Ports: 22, 25565/tcp, 19132/udp             │  │   │
│  │  └───────────────────┼───────────────────────────┘  │   │
│  │                      │                              │   │
│  │  ┌───────────────────▼───────────────────────────┐  │   │
│  │  │     EBS Volume (50GB gp3) - Persistent Data   │  │   │
│  │  │     /data/docker-volumes/blockhaven-mc-data   │  │   │
│  │  └───────────────────────────────────────────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │     S3 Bucket: blockhaven-mc-backups               │   │
│  │     (World backups, plugin configs)                 │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │     Elastic IP (Optional)                           │   │
│  │     Consistent address across stop/start            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Security Notes

1. **SSH Access**: Restrict `ALLOWED_SSH_CIDR` to your IP in `.env.aws`
2. **RCON Password**: Use a strong password, never commit to git
3. **IAM Role**: EC2 has minimal S3 permissions (backup bucket only)
4. **Secrets**: `.env.aws` is gitignored, keep passwords safe
5. **Updates**: The Minecraft image auto-updates plugins on restart
