# BlockHaven Admin Dashboard Setup Guide

This guide covers setting up the admin dashboard for the BlockHaven Minecraft server.

## Prerequisites

- GitHub account
- AWS account with EC2 instance
- Cloudflare account (for hosting)

## 1. GitHub OAuth App

1. Go to https://github.com/settings/developers
2. Click "New OAuth App"
3. Fill in:
   - **Application name:** BlockHaven Admin
   - **Homepage URL:** https://bhsmp.com
   - **Authorization callback URL:** https://bhsmp.com/api/auth/callback/github
4. Click "Register application"
5. Copy **Client ID** to `GITHUB_CLIENT_ID`
6. Generate a new **Client Secret** and copy to `GITHUB_CLIENT_SECRET`

### For Local Development

Create a separate OAuth app with:
- Homepage URL: http://localhost:4321
- Callback URL: http://localhost:4321/api/auth/callback/github

## 2. AWS IAM User

Create an IAM user with the following policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EC2Management",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeInstances",
        "ec2:StartInstances",
        "ec2:StopInstances"
      ],
      "Resource": "*"
    },
    {
      "Sid": "CloudWatchLogs",
      "Effect": "Allow",
      "Action": [
        "logs:GetLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": "arn:aws:logs:us-east-2:*:log-group:blockhaven-minecraft:*"
    },
    {
      "Sid": "SSMCommands",
      "Effect": "Allow",
      "Action": [
        "ssm:SendCommand",
        "ssm:GetCommandInvocation"
      ],
      "Resource": [
        "arn:aws:ssm:us-east-2:*:document/AWS-RunShellScript",
        "arn:aws:ec2:us-east-2:*:instance/i-*"
      ]
    }
  ]
}
```

## 3. Cloudflare KV Namespaces

Create two KV namespaces:

```bash
wrangler kv:namespace create BLOCKHAVEN_RATE_LIMITS
wrangler kv:namespace create BLOCKHAVEN_AUDIT
```

Add the IDs to `wrangler.toml`.

## 4. Environment Variables

### Local Development

Copy `.env.example` to `.env` and fill in values.

### Production (Cloudflare)

Set secrets in Cloudflare Pages dashboard or via CLI:

```bash
wrangler pages secret put AUTH_SECRET
wrangler pages secret put GITHUB_CLIENT_ID
wrangler pages secret put GITHUB_CLIENT_SECRET
wrangler pages secret put AWS_ACCESS_KEY_ID
wrangler pages secret put AWS_SECRET_ACCESS_KEY
# ... etc
```

## 5. CloudWatch Logs (Optional)

For the logs viewer to work, install CloudWatch agent on EC2:

1. Install agent: `sudo yum install -y amazon-cloudwatch-agent`
2. Configure to send Docker logs to `blockhaven-minecraft` log group
3. Start agent: `sudo systemctl start amazon-cloudwatch-agent`

## 6. Verify Setup

1. Run locally: `npm run dev`
2. Visit http://localhost:4321/login
3. Sign in with GitHub
4. Verify dashboard loads with server status

## Troubleshooting

### "Access denied" on login
- Check `ADMIN_GITHUB_USERNAMES` includes your username (case-insensitive)

### AWS errors
- Verify credentials are correct
- Check IAM policy allows required actions
- Verify region matches EC2 instance

### Rate limiting issues in dev
- KV may not be available locally
- Rate limiting will skip if KV undefined
