# IAM User Setup for BlockHaven Deployment

This guide will help you create a dedicated IAM user with minimal permissions for deploying BlockHaven to AWS.

## Why Create a Dedicated IAM User?

✅ **Best Practice:** Principle of least privilege
✅ **Security:** Isolates credentials (if leaked, only this project affected)
✅ **Portability:** Works on WSL, Linux laptop, CI/CD, etc.
✅ **No Config Files:** Just environment variables in `.env.aws`

---

## Step 1: Create IAM User

1. Go to AWS IAM Console: https://console.aws.amazon.com/iam/home#/users
2. Click **"Create user"**
3. User name: `blockhaven-deploy`
4. **Uncheck** "Provide user access to AWS Management Console" (we only need programmatic access)
5. Click **"Next"**

---

## Step 2: Attach Permissions

### Option A: Managed Policies + Small Inline Policy (Recommended)

This approach uses AWS Managed Policies to avoid inline policy size limits and incremental permission issues.

**Step 2a: Attach Managed Policies**

1. Select **"Attach policies directly"**
2. Search for and select these two policies:
   - **`AmazonEC2FullAccess`**
   - **`AWSCloudFormationFullAccess`**
3. Click **"Next"**
4. Click **"Create user"**

**Step 2b: Add Inline Policy for IAM and S3**

5. After user is created, click on the user name `blockhaven-deploy`
6. Go to **"Permissions"** tab
7. Click **"Add permissions"** → **"Create inline policy"**
8. Click **"JSON"** tab
9. Copy and paste this policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "IAMRoleCreation",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:DeleteRole",
        "iam:GetRole",
        "iam:PassRole",
        "iam:AttachRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:GetRolePolicy",
        "iam:CreateInstanceProfile",
        "iam:DeleteInstanceProfile",
        "iam:GetInstanceProfile",
        "iam:AddRoleToInstanceProfile",
        "iam:RemoveRoleFromInstanceProfile",
        "iam:TagRole",
        "iam:UntagRole"
      ],
      "Resource": [
        "arn:aws:iam::*:role/blockhaven-*",
        "arn:aws:iam::*:instance-profile/blockhaven-*"
      ]
    },
    {
      "Sid": "S3BucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetBucketLocation"
      ],
      "Resource": [
        "arn:aws:s3:::blockhaven-*",
        "arn:aws:s3:::blockhaven-*/*"
      ]
    }
  ]
}
```

10. Click **"Next"**
11. Policy name: `BlockHavenScopedAccess`
12. Click **"Create policy"**

**Summary:** This user will have:
- ✅ Full EC2 access (via AmazonEC2FullAccess managed policy)
- ✅ Full CloudFormation access (via AWSCloudFormationFullAccess managed policy)
- ✅ Scoped IAM access (only blockhaven-mc-instance-role)
- ✅ Scoped S3 access (only blockhaven-mc-backups bucket)

---

### Option B: Fully Managed Policies (Simplest but Broadest Permissions)

If you want the absolute simplest setup:

1. Select **"Attach policies directly"**
2. Search and attach these policies:
   - `AmazonEC2FullAccess`
   - `AmazonS3FullAccess`
   - `IAMFullAccess`
   - `AWSCloudFormationFullAccess`
3. Click **"Next"** then **"Create user"**

**⚠️ Warning:** This gives very broad permissions. Only use for personal/dev accounts.

---

## Step 3: Create Access Keys

1. After user is created, click on the user name `blockhaven-deploy`
2. Go to **"Security credentials"** tab
3. Scroll down to **"Access keys"**
4. Click **"Create access key"**
5. Use case: Select **"Command Line Interface (CLI)"**
6. Check the confirmation box
7. Click **"Next"**
8. Description: `BlockHaven deployment from WSL/Linux`
9. Click **"Create access key"**

**IMPORTANT:** Copy both values:
- **Access key ID** (starts with `AKIA...`)
- **Secret access key** (long random string - ONLY shown once!)

---

## Step 4: Add Credentials to .env.aws

1. Edit `/home/aaronprill/projects/blockhaven/mc-server/aws/.env.aws`
2. Replace the placeholder values:
   ```bash
   AWS_ACCESS_KEY_ID=AKIA... (paste your key ID)
   AWS_SECRET_ACCESS_KEY=... (paste your secret)
   ```
3. Save the file

**Security Note:** Never commit `.env.aws` to git (it's already in `.gitignore`)

---

## Step 5: Verify Setup

Test that your credentials work:

```bash
cd /home/aaronprill/projects/blockhaven/mc-server/aws

# Load environment variables
source .env.aws

# Test AWS CLI access
aws sts get-caller-identity \
  --region $AWS_REGION

# Should output:
# {
#     "UserId": "AIDA...",
#     "Account": "123456789012",
#     "Arn": "arn:aws:iam::123456789012:user/blockhaven-deploy"
# }
```

If you see the output with your account info, you're ready to deploy! ✅

---

## Step 6: Ready to Deploy!

Once credentials are verified, you're ready to deploy:

```bash
cd /home/aaronprill/projects/blockhaven/mc-server/aws

# Dry run first
./deploy.sh --dry-run

# Deploy for real
./deploy.sh
```

---

## Security Best Practices

✅ **Never commit `.env.aws`** to git (already in `.gitignore`)
✅ **Don't share access keys** in chat, email, or screenshots
✅ **Rotate keys periodically** (every 90 days recommended)
✅ **Delete old keys** when no longer needed
✅ **Use inline policy** for minimal permissions (Option A)

---

## Troubleshooting

### "Access Denied" errors during deployment
- Check that all permissions from the policy are attached
- Verify you're using the correct AWS region (us-east-1)
- Make sure S3 bucket `blockhaven-mc-backups` exists

### Can't create IAM role
- Ensure IAM permissions in the policy include `iam:CreateRole` and `iam:PassRole`

### Credentials not loading
- Make sure `.env.aws` has correct syntax (no spaces around `=`)
- Try running: `source .env.aws` then `echo $AWS_ACCESS_KEY_ID`

---

## Next Steps

After completing this setup:
1. Copy `blockhaven-key.pem` to USB drive for your Linux laptop
2. Run `./deploy.sh --dry-run` to verify configuration
3. Run `./deploy.sh` to deploy to AWS
4. Update Cloudflare DNS for `play.bhsmp.com`

---

**Created:** January 22, 2026
**For:** BlockHaven AWS Deployment
